/*
 * 1)
 * Returns table with all transferred_points between peers and total points.
 * The number is negative if peer 2 received more points from peer 1.
 */
create or replace function fnc_readable_transferred_points()
	returns table(Peer1 varchar, Peer2 varchar, PointsAmount int) as
$$
begin
	return query(
		select tp1.CheckingPeer as Peer1,
			tp1.CheckedPeer as Peer2,
			(case
				when tp2.ID is not null then
					(tp1.PointsAmount - tp2.PointsAmount)
				else
					tp1.PointsAmount
				end
			) as PointsAmount
		from TransferredPoints tp1
			left join TransferredPoints tp2 on tp2.ID != tp1.ID
				and tp1.checkingpeer = tp2.checkedpeer
				and tp1.checkedpeer = tp2.checkingpeer
	);
end;
$$ language plpgsql;


/*
 * 2)
 * Returns all successfully passed tasks
 */
create or replace function fnc_successfully_passed_tasks()
	returns table(Peer varchar, Task varchar, XP int) as
$$
begin
	return query (
		select v_all_passing_checks1.Checked as Peer,
			v_all_passing_checks1.Task,
			XP.XPAmount as XP
		from v_all_passing_checks1
			join XP on XP."Check" = v_all_passing_checks1.Checks_ID
		order by 1
	);
end;
$$ language plpgsql;


/*
 * 3)
 * Returns list of peers who have not left campus all the 'finding_day'
 */
create or replace function fnc_hold_day_in_campus_list(finding_day date)
	returns table("Peer" varchar) as
$$
begin
	return query(
		select peer
		from(
			select peer, time, date, (date + time)::timestamp as login,
				lead((date + time)::timestamp) over (partition by peer order by date, time) as logout
			from timetracking
		) as school_time
		where time = '00:00:00' and (logout - login) >= interval '23:59:59'
			and date = finding_day
	);
end;
$$ language plpgsql;


/*
 * 4)
 * Calculate the change in the number of peer points of each
 * peer using the TransferredPoints table
 */
create or replace procedure prcdr_total_points(ref refcursor) as
$$
begin
	open ref for
		with cte_checking as (
			select
				checkingpeer as Peer,
				sum(pointsamount) as total_plus_count
			from TransferredPoints
			group by checkingpeer
			order by 1
		)
		select checked.Peer,
			(coalesce(total_plus_count, 0)
				- coalesce(total_minus_count, 0)) as PointsChange
		from cte_checking
			full join (
				select
					checkedpeer as Peer,
					sum(pointsamount) as total_minus_count
				from TransferredPoints
				group by checkedpeer
				order by 1
			) as checked using(Peer);
end;
$$ language plpgsql;


/*
 * 5)
 * Calculate the change in the number of peer points of each
 * peer using the fnc_readable_transferred_points() function
 */
create or replace procedure prcdr_totall_points_from_func(ref refcursor) as
$$
begin
	open ref for
		with cte_peer1_count as (
			select peer1 as Peer, count(peer1) as total_plus_count
			from fnc_readable_transferred_points()
			group by peer1
			order by 1
		)
		select peer2_count.Peer,
			(coalesce(total_plus_count, 0)
				- coalesce(total_minus_count, 0)) as PointsChange
		from cte_peer1_count
			full join (
				select peer2 as Peer, count(peer2) as total_minus_count
				from fnc_readable_transferred_points()
				group by peer2
				order by 1
			) as peer2_count using(Peer);
end;
$$ language plpgsql;


/*
 * 6)
 * Find the most frequently checked task for each day
 */
create or replace procedure prcdr_frequently_checked_task(ref refcursor) as
$$
begin
	open ref for
		with cte_check as (
			select date, task, count(date) as count
			from Checks
			group by date, task
			order by date
		)
		select c1.date as Day,
			c1.task
		from cte_check c1
			left join cte_check c2 on c2.task != c1.task
				and c2.date = c1.date and c2.count > c1.count
		where c2.date is null;
end;
$$ language plpgsql;


/*
 * 7)
 * Find all peers who have completed the whole 'block_name'
 * block of tasks and the completion date of the last task
 */
create or replace procedure prcdr_passed_task_block(
	ref refcursor,
	block_name varchar
) as
$$
begin
	open ref for
		with cte_task_block_name as (
			select title as task
			from Tasks
			where substring(title from '.+?(?=\d{1,2})') = block_name
			order by 1 DESC
			limit 1
		)
		select v_apch.checked as Peer,
			ch.Date as Day
		from v_all_passing_checks as v_apch
			join cte_task_block_name as cte_tbn using(task)
			join Checks as ch on ch.ID = v_apch.checks_id
		where v_apch.resume_f is null
		order by ch.Date;
end;
$$ language plpgsql;


/*
 * 8)
 * Determine the peer for checking who was recommended by the peer's friends
 * (peer with maximum count of recommendation from all friends)
 */
create or replace procedure prcdr_recommended_peer(ref refcursor) as
$$
begin
	open ref for
		select distinct on (nickname) nickname as peer,
			recommendedpeer
		from (
			select v_af.nickname, r.recommendedpeer,
				count(r.recommendedpeer)
			from v_peers_friends as v_af
				join recommendations as r on r.peer = v_af.friend
			where v_af.nickname != r.recommendedpeer
			group by v_af.nickname, r.recommendedpeer
			order by v_af.nickname, count desc
		) as recommendations_count;
end;
$$ language plpgsql;


/*
 * 9)
 * Determine the percentage of peers who:
 * 	- Started only 'block_1'
 * 	- Started only 'block_2'
 * 	- Started both
 * 	- Have not started any of them
 */
create or replace procedure prcdr_percenge_started_block(
	ref refcursor,
	block_1 varchar,
	block_2 varchar
) as
$$
declare
	peers_number numeric := (select count(*) from peers);
begin
	open ref for
		with cte_passed_peers as (
			select (
					(
						select count(peer) as block1
						from fnc_who_started_block(block_1)
						where count = 1
					) * 100 / peers_number
				)::int as StartedBlock1,
				(
					(
						select count(peer) as block2
						from fnc_who_started_block(block_2)
						where count = 1
					) * 100 / peers_number
				)::int as StartedBlock2,
				(
					(
						select count(*) as block12
						from fnc_who_started_block(block_1) as tmp
						where block_name = block_2
					) * 100 / peers_number
				)::int as StartedBothBlocks
		)
		select *,
			(
				100 - (StartedBlock1 + StartedBlock2 + StartedBothBlocks)
			) as DidntStartAnyBlock
		from cte_passed_peers;
end;
$$ language plpgsql;


/*
 * 10)
 * Determine the percentage of peers who have successfully
 * and unsuccessfully passed a check on their birthday
 */
create or replace procedure prcdr_passed_on_birthday(ref refcursor) as
$$
begin
	open ref for
		with cte_states_count as (
			select resume as state,
				count(*)
			from v_all_passing_checks1 as v_alch
				join Peers as p on p.nickname = v_alch.checked
					and extract(month from p.birthday)
						= extract(month from v_alch.checks_date)
					and extract(day from p.birthday)
						= extract(day from v_alch.checks_date)
			group by resume
		)
		select (case cte_sc1.state
					when 'S' then
						round(
							(cte_sc1.count * 100
							/ (cte_sc1.count + cte_sc2.count)::numeric), 0
						)
		            when 'F' then
						round(
							(cte_sc2.count * 100
							/ (cte_sc1.count + cte_sc2.count)::numeric), 0
						)
					else 0
					end
				) as SuccessfulChecks,
				(case cte_sc1.state
					when 'F' then
						round(
							(cte_sc1.count * 100
							/ (cte_sc1.count + cte_sc2.count)::numeric), 0
						)
					else round(
							(cte_sc2.count * 100
							/ (cte_sc1.count + cte_sc2.count)::numeric), 0
						)
					end
				) as UnsuccessfulChecks
		from cte_states_count as cte_sc1
			join cte_states_count as cte_sc2 on cte_sc2.state != cte_sc1.state
		limit 1;
end;
$$ language plpgsql;


/*
 * 11)
 * Determine all peers who did the given 'task_1' and 'task_2',
 * but did not do 'task_3'
 */
create or replace procedure prcdr_did_peer_tasks(
	ref refcursor,
	task_1 varchar,
	task_2 varchar,
	task_3 varchar
) as
$$
begin
	open ref for
		select peer
		from fnc_who_started_task(task_1) as fnc_ipb
		where task_name = task_2 and peer not in(
			select peer
			from fnc_who_started_task(task_1) as fnc_ipb
			where task_name = task_3
		);
end;
$$ language plpgsql;


/*
 * 12)
 * Output the number of mandatory preceding tasks for each task
 * using recursive common table expression
 */
create or replace procedure prcdr_preceding_tasks(ref refcursor) as
$$
begin
	open ref for
		with recursive cte_tasks_count as (
			select title,
				0 as count,
				parenttask
			from tasks
			where parenttask is null
			union all
			select t.title,
				count + 1,
				t.parenttask
			from tasks as t
				join cte_tasks_count as cte_tc on cte_tc.title = t.parenttask
		)
		select title as Task,
			count as PrevCount
		from cte_tasks_count
		order by Task;
end;
$$ language plpgsql;


/*
 * 13)
 * Determine days which have at least 'N' consecutive successful checks
 */
create or replace procedure prcdr_checks_lucky_days (
	ref refcursor,
	N numeric
) as
$$
begin
	open ref for
		with
			cte_previous_state as (
				select *,
					lag(resume, 1, '-') over (partition by checks_date order by checks_id) as l
				from v_all_passing_checks1
			),
			cte_successful_count as (
				select checks_date, count(*) over (partition by checks_date)
				from cte_previous_state
				    join Tasks on cte_previous_state.task = Tasks.Title
				    join XP on cte_previous_state.checks_id = XP."Check"
				where resume = 'S' and (l = 'S' or l = '-') and
                    XP.XPAmount >= Tasks.MaxXP * 0.8
			)
		select checks_date
		from (
			select checks_date, count(*)
			from cte_successful_count
			group by checks_date
		) as finale_count
		where count > (N - 1);
end;
$$ language plpgsql;


/*
 * 14)
 * Determine the peer with the highest amount of XP
 */
create or replace procedure prcdr_peer_with_highest_xp(
	ref refcursor
) as
$$
begin
	open ref for
		select checked as Peer,
			sum(xpamount) as XP
		from v_all_passing_checks1 v_apch1
			join XP on XP."Check" = v_apch1.checks_id
		where resume <> 'F'
		group by checked
		order by XP desc
		limit 1;
end;
$$ language plpgsql;


/*
 * 15)
 * Determine the peers that came before the 'before_time'
 * at least 'N' times during the whole time
 */
create or replace procedure prcdr_came_before(
	ref refcursor,
	before_time time,
	N bigint
) as
$$
begin
	open ref for
		select distinct peer
		from (
			select peer, count(peer) over (partition by peer)
			from TimeTracking
			where time < before_time and state = 1
		) as who_came
		where count >= N
		order by peer;
end;
$$ language plpgsql;


/*
 * 16)
 * Determine the peers who left the campus more than 'M'
 * times during the last 'N' days
 */
create or replace procedure prcdr_left_during_time(
	ref refcursor,
	M bigint,
	N bigint
) as
$$
begin
	open ref for
		select distinct peer
		from (
		select peer, count(peer) over (partition by peer)
		from timetracking
		where (date between current_date - (N || 'day')::interval
			and current_date)
			and state = 2
		) as who_left
		where count > M
		order by peer;
end;
$$ language plpgsql;


/*
 * 17)
 * Determine for each month of year the percentage of early
 * peers visits (before 12:00) in their birthdays
 */
create or replace procedure prcdr_early_in_birthday(ref refcursor) as
$$
begin
	open ref for
		with
			cte_birthday_visits as (
				select timetracking.date,
					extract(month from timetracking.date) as month,
					time
				from timetracking
					join peers on peers.nickname = timetracking.peer
						and extract(month from peers.birthday) = extract(month from timetracking.date)
				where timetracking.state = 1
			),
			cte_generate_months as (
				select generate_series(
					'2000-01-01'::date,
					'2000-12-01'::date,
					'1 month'
				) as timestamp_math
			)
		select
			to_char(timestamp_math, 'Month') as Month,
			(case
				when extract(month from timestamp_math) = month
					then round((early * 100 / total), 0)
				else
					0
				end
			) as EarlyEntries,
		    early, total
		from (
			select distinct on (month) month,
				count(*) over (partition by month) as total
			from cte_birthday_visits as cte_bv
		) as total_visits
			join (
				select distinct on (month) month,
					count(*) over (partition by month) as early
					from cte_birthday_visits as cte_bv
					where time < '12:00:00'
			) as early_visits using(month)
			right join cte_generate_months on extract(month from timestamp_math) = month;
end;
$$ language plpgsql;
