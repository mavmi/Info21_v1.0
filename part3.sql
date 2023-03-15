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

-- select * from fnc_readable_transferred_points() order by 1;


/*
 * 2)
 * Returns all successfully passed tasks
 */
create or replace function fnc_successfully_passed_tasks()
	returns table(Peer varchar, Task varchar, XP int) as
$$
begin
	return query (
		select v_all_passing_checks.Checked as Peer,
			v_all_passing_checks.Task,
			XP.XPAmount as XP
		from v_all_passing_checks
			join XP on XP."Check" = v_all_passing_checks.Checks_ID
		order by 1
	);
end;
$$ language plpgsql;


/*
 * 3)
 * Retuens list of peers who have not left campus all the 'finding_day'
 */
create or replace function fnc_hold_day_in_campus_list(finding_day time)
	returns table(Peer varchar) as
$$
begin
	return query(
		select tt1.Peer
		from timetracking tt1
			right join timetracking tt2 using(Peer)
		where tt2.state != tt1.state and tt1.state != 2
			and tt1.time = '00:00:00' and tt2.time = '23:59:59'
	);
end;
$$ language plpgsql;


/*
 * 4)
 * Find the percentage of successful and unsuccessful checks for all time
 */
create or replace procedure prcdr_passed_state_percentage(ref refcursor) as
$$
begin
	open ref for
		with cte_count_states as (
			select count(resume_f) as f_sum,
				count(resume_s) as s_sum
			from v_all_passing_checks
		)
		select (s_sum * 100 / (s_sum + f_sum)) as SuccessfulChecks,
			(f_sum * 100 / (s_sum + f_sum)) as UnsuccessfulChecks
		from cte_count_states;
end;
$$ language plpgsql;

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_passed_state_percentage('ref');
-- fetch all in "ref";


/*
 * 5)
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
				count(pointsamount) as total_plus_count
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
					count(pointsamount) as total_minus_count
				from TransferredPoints
				group by checkedpeer
				order by 1
			) as checked using(Peer);
end;
$$ language plpgsql;

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_total_points_changes('ref');
-- fetch all in "ref";


/*
 * 6)
 * Calculate the change in the number of peer points of each
 * peer using the fnc_readable_transferred_points() funcion
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

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_totall_points_from_func('ref');
-- fetch all in "ref";


/*
 * 7)
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

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_frequently_checked_task('ref');
-- fetch all in "ref";


/*
 * 8)
 * Determine the duration of the last P2P check
 * (time between 'Start' and 'Success'/'Failure')
 */
create or replace procedure prcdr_checking_time_duration(ref refcursor) as
$$
begin
	open ref for
		with cte_check as (
			select *, count("Check") over (partition by "Check")
			from P2P
			order by id desc
		)
		select make_time(
			(extract(hour from (end1.time - start2.time)))::int,
			(extract(minute from (end1.time - start2.time)))::int,
			(extract(second from (end1.time - start2.time)))
		) as CheckDuration
		from cte_check end1
			left join cte_check start2 on start2."Check" = end1."Check"
				and end1.state != start2.state
		where end1.count = 2 limit 1;
end;
$$ language plpgsql;

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_checking_time_duration('ref');
-- fetch all in "ref";


/*
 * 9)
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

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_passed_task_block('ref', 'A');
-- fetch all in "ref";



/*
 * 10)
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

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_recommended_peer('ref');
-- fetch all in "ref";


/*
 * REALIZATION WITH CROSS JOIN:
 *
 * create or replace procedure prcdr_percenge_started_block(
 * 	ref refcursor,
 * 	block_1 varchar,
 * 	block_2 varchar
 * ) as
 * $$
 * declare
 * 	peers_number numeric := (select count(*) from peers);
 * begin
 * 	open ref for
 * 		select (block1 * 100 / peers_number)::int as StartedBlock1,
 * 			(block2 * 100 / peers_number)::int as StartedBlock2,
 * 			(block12 * 100 / peers_number)::int as StartedBothBlocks,
 * 			((peers_number - (block1 + block2 + block12))
 * 				* 100 / peers_number)::int as DidntStartAnyBlock
 * 		from (
 * 				select count(peer) as block1
 * 				from fnc_is_peer_passed_block(block_1)
 * 				where count = 1
 * 			) as block1
 * 			cross join (
 * 				select count(peer) as block2
 * 				from fnc_is_peer_passed_block(block_2)
 * 				where count = 1
 * 			) as block2
 * 			cross join (
 * 				select count(*) as block12
 * 				from fnc_is_peer_passed_block(block_1) as tmp
 * 					join v_peers_tasks_blocks as v_ptb2 on v_ptb2.peer = tmp.peer
 * 						and v_ptb2.task_block = block_2
 * 				group by v_ptb2.peer
 * 				limit 1
 * 			) as both_blocks;
 * end;
 * $$ language plpgsql;
 */


/*
 * 11)
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
						from fnc_is_peer_passed_block(block_1)
						where count = 1
					) * 100 / peers_number
				)::int as StartedBlock1,
				(
					(
						select count(peer) as block2
						from fnc_is_peer_passed_block(block_2)
						where count = 1
					) * 100 / peers_number
				)::int as StartedBlock2,
				(
					(
						select count(*) as block12
						from fnc_is_peer_passed_block(block_1) as tmp
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

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_percenge_started_block('ref', 'CPP', 'DO');
-- fetch all in "ref";


/*
 * 12)
 * Determine 'n' peers with the greatest number of friends
 */
create or replace procedure prcdr_greates_friends_number(
	ref refcursor,
	n bigint
) as
$$
begin
	open ref for
		select nickname as Peer,
			count(friend) as FriendsCount
		from v_peers_friends
		group by nickname
		order by FriendsCount desc
		limit n;
end;
$$ language plpgsql;

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_greates_friends_number('ref', 5);
-- fetch all in "ref";


/*
 * 12)
 * Determine the percentage of peers who have successfully
 * and unsuccessfully passed a check on their birthday
 */
create or replace procedure prcdr_passed_on_birthday(ref refcursor) as
$$
begin
	open ref for
		with cte_states_count as (
			select (case
						when resume_f is null then resume_s
						else resume_f END
					) as state,
				count(*)
			from v_all_passing_checks as v_alch
				join Peers as p on p.nickname = v_alch.checked
					and extract(month from p.birthday)
						= extract(month from v_alch.checks_date)
					and extract(day from p.birthday)
						= extract(day from v_alch.checks_date)
			group by resume_f, resume_s
		)
		select (case cte_sc1.state
					when 'S' then
						round(
							(cte_sc1.count * 100
							/ (cte_sc1.count + cte_sc2.count)::numeric), 0
						)
					else round(
							(cte_sc2.count * 100
							/ (cte_sc1.count + cte_sc2.count)::numeric), 0
						)
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

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_passed_on_birthday('ref');
-- fetch all in "ref";


/*
 * 14)
 * Determine the total amount of XP gained by each peer
 */
create or replace procedure prcdr_total_peer_xp_amount(ref refcursor) as
$$
begin
	open ref for
		with cte_peers_xp as (
			select
				checked,
				task,
				max(xpamount)
			from v_all_passing_checks as v_apch
				join XP on XP."Check" = v_apch.checks_id and resume_f is null
			group by checked, task
			order by v_apch.checked, v_apch.task
		)
		select checked as Peer,
			sum(max) as XP
		from cte_peers_xp
		group by checked
		order by XP desc;
end;
$$ language plpgsql;

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_total_peer_xp_amount('ref');
-- fetch all in "ref";


/*
 * 15)
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
		from fnc_is_peer_passed_block(task_1) as fnc_ipb
		where block_name = task_2 and peer not in(
			select peer
			from fnc_is_peer_passed_block(task_1) as fnc_ipb
			where block_name = task_3
		);
end;
$$ language plpgsql;

-- START PROCEDURE WITH REFCURSOR --
-- call prcdr_did_peer_tasks('ref', 'SQL', 'A', 'DO');
-- fetch all in "ref";


-- CANNOT CREATE DECITION FOR EX 16
/*
with recursive cte_previous_tasks(block_task, parent, count) as (
	(
		select title,
			parenttask,
			0
		from Tasks
		where title = 'DO2'
	)
	union all
	select t.title,
		parenttask,
		count + 1
	from Tasks as t
		join cte_previous_tasks as cte_pt
			on cte_pt.parent = t.title
)
select * from cte_previous_tasks
	limit 100;



with
	recursive cte_previous_tasks(block_task, parent, count) as (
		(
			select title,
				parenttask,
				0
			from cte_all_tasks
			where id = 1
		)
		union all
		select t.title,
			parenttask,
			count + 1
		from Tasks as t
			join cte_previous_tasks as cte_pt
				on cte_pt.parent = t.title
	),
	cte_all_tasks as (
		select *, row_number() over () as id
		from tasks
	)
select * from cte_previous_tasks;

with
  recursive r(n) as (
    values(1)

    union all

    select n + 1
    from r
    where n < 5
    ),

  a2(n) as (
    select 99)

(
  select n from r
  union all
  select n from a2
)
order by n desc;

-- substring(block_task from '.+?(?=\d{1,2})')
*/

select v_apch.resume_f,
	v_apch.resume_s,
	v_apch.checks_id,
	v_apch.task,
	v_apch.Checks_Date
	-- XP.XPAmount as scores,
	-- Tasks.MaxXP as max_scores
from v_all_passing_checks as v_apch
	--join XP on XP."Check" = v_apch.checks_id
	--join Tasks on Tasks.Title = v_apch.task
--where resume_f is null;
order by v_apch.Checks_Date

create sequence if not exists seq
	start 1,
    increment 1;



select *, count(*) over (partition by checks_date)
from(
select *,  lag(resum, 1, '-') over (partition by checks_date order by checks_id) as l
from (
select checks_id, checks_date,
	( case
     	when resume_f is null then 'S' else 'F' end
      ) as resum
from v_all_passing_checks
) as f ) as d
where resum = 'S' and (l = 'S' or l = '-')
