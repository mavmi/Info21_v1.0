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

select * from fnc_readable_transferred_points() order by 1;


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
			(coalesce(total_plus_count, 0) - coalesce(total_minus_count, 0)) as PointsChange
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
			(coalesce(total_plus_count, 0) - coalesce(total_minus_count, 0)) as PointsChange
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



-- FOR_EX09: How to tacke the last task in block_task
select *
from Tasks
where substring(title from '.+?(?=\d{1,2})') = 'A'
order by 1 DESC
limit 1;

