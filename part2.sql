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


create or replace procedure prcdr_fnc_verter(
	checked_peer varchar,
	task_name varchar,
	status check_status,
	argtime time
) as
$$
begin
	insert into Verter values(

	);
end;
$$ language plpgsql;


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


create or replace function trg_fnc_xp_check_correct_insert() returns trigger as
$$
begin
	if (
		(
			select (new.XPAmount <= Tasks.MaxXP)
			from Checks
				join P2P on P2P."Check" = Checks.ID
				join Tasks on Tasks.Title = Checks.Task
			where Checks.ID = new."Check" and P2P.State = 'Success'
		)
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
