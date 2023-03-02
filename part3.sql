create or replace function fnc_readable_transferred_points()
	returns table(Peer1 varchar, Peer2 varchar, PointsAmount int) as
$$
begin
	return query(
		select *
		from TransferredPoints tp1
			left join TransferredPoints tp2 on tp2.ID > tp1.ID
				and tp1.checkingpeer = tp2.checkedpeer
				and tp1.checkedpeer = tp2.checkingpeer
	);
end;
$$ language plpgsql;


create or replace function fnc_successfully_passed_tasks()
	returns table(Peer varchar, Task varchar, XP int) as
$$
begin
	return query (
		select Peers.Nickname as Peer,
			Tasks.Title as Tasks,
			XP.XPAmount as XP
		from Checks
			join P2P on P2P."Check" = Checks.ID
				and P2P.State = 'Success'
			join Peers on Peers.Nickname = Checks.Peer
			join Tasks on Tasks.Title = Checks.Task
			join XP on XP."Check" = Checks.ID
		order by 1
	);
end;
$$ language plpgsql;
