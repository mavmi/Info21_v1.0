/*
 * 1. If the status is "start" add a record in the Checks table (use today's date)
 * 2. Add a record in the P2P table:
 * 	- if status is "start" - P2P.Check is just added record in the Checks
 * 	- if status isn't "start" - P2P.Check is already added Check in Checks table
 */
create or replace procedure prcdr_fnc_p2p(
	checked_peer varchar,
	checker_peer varchar,
	task_name varchar,
	status check_status,
	argtime time
) as
$$
begin
	if (status = 'Start') then
		insert into Checks values(
			(select coalesce((max(ID) + 1), 1) from Checks),
			checked_peer,
			task_name,
			current_date
		);
		insert into P2P values(
			(select coalesce((max(ID) + 1), 1) from P2P),
			(select (max(ID)) from Checks),
			checker_peer,
			status,
			argtime
		);
	else
		insert into P2P values(
			(select (max(ID) + 1) from P2P),
			(
				select "Check"
				from P2P
					join Checks on Checks.ID = P2P."Check"
						and Checks.Task = task_name
						and Checks.Peer = checked_peer
				where P2P.CheckingPeer = checker_peer and P2P.state = 'Start'
			),
			checker_peer,
			status,
			argtime
		);
	end if;
end;
$$ language plpgsql;


/*
 * Add a record to the Verter table:
 * the latest (by time) P2P checking of 'checked_peer' with 'task_name'
 * where P2P.State is 'Success'
 */
create or replace procedure prcdr_fnc_verter(
	checked_peer varchar,
	task_name varchar,
	status check_status,
	argtime time
) as
$$
declare
	check_id int := (
		select Checks.ID
		from Checks
			join P2P on P2P."Check" = Checks.ID
				and P2P.State = 'Success'
		where Checks.Task = task_name and Checks.Peer = checked_peer
		order by Checks.Task desc, P2P.Time desc
		limit 1
	);
begin
	if (coalesce(check_id, 0) != 0) then
		insert into Verter values(
			(select coalesce((max(ID) + 1), 1) from Verter),
			check_id,
			status,
			argtime
		);
	end if;
end;
$$ language plpgsql;


/*
 * after adding a record with the "start" status to the P2P table,
 * to add the corresponding record in the TransferredPoints table
 */
create or replace function trg_fnc_p2p_insert_transferred_poins() returns trigger as
$$
begin
	if (new.state = 'Start') then
		insert into TransferredPoints values(
			(select coalesce((max(ID) + 1), 1) from TransferredPoints),
			new.CheckingPeer,
			(select Peer from Checks where ID = new."Check"),
			1
		);
	end if;
	return new;
end;
$$ language plpgsql;

create trigger trg_p2p_insert_transferred_points
after insert on P2P
for each row
execute procedure trg_fnc_p2p_insert_transferred_poins();


/*
 * Check if adding record to the XP is correct:
 * 	- The number of XP does not exceed the maximum available
 * 	- Checked should be 'Success'
 */
create or replace function trg_fnc_xp_check_correct_insert() returns trigger as
$$
begin
	if (
		(
			select count(*) filter (where new.XPAmount <= Tasks.MaxXP)
			from Checks
				join v_all_passing_checks as v_apch on v_apch.Checks_ID = Checks.ID
				join Tasks on Tasks.Title = Checks.Task
			where v_apch.resume_s is not null
		) > 0
	) then
		return new;
	else return null;
	end if;
end;
$$ language plpgsql;

create trigger trg_xp_check_insert
before insert on XP
for each row
execute procedure trg_fnc_xp_check_correct_insert();
