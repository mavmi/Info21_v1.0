/*
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
			left join TransferredPoints tp2 on tp2.ID > tp1.ID
				and tp1.checkingpeer = tp2.checkedpeer
				and tp1.checkedpeer = tp2.checkingpeer
	);
end;
$$ language plpgsql;


/*
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
 * Find the percentage of successful and unsuccessful checks for all time
 */
create or replace procedure prcdr_fnc_passed_state_percentage(ref refcursor) as
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

-- START PROCEDURE WITH REFCURSOR
-- call prcdr_fnc_passed_state_percentage('ref');
-- fetch all in "ref";


