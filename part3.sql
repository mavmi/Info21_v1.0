create or replace function fnc_readable_transferred_points()
	returns table(Peer1 varchar, Peer2 varchar, PointsAmount int) as
$$
begin
	return query(
		select CheckingPeer as Peer1,
			CheckedPeer as Peer2,
			TransferredPoints.PointsAmount as "PointsAmount"
		from TransferredPoints
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
