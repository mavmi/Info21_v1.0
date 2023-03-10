/*
 * Join tables P2P, Checks and Verter to one table which includes:
 * Check_id | CheckedPeer | CheckingPeer | Task | p2pState | VerterState
 *
 * Besides, it keeps resume state marker for every row qith rules below:
 * - 'S' marker: Verter.State = 'Success' or P2P.state = 'Success'
 * 			  (if project don't checked by Vector)
 * - 'F' marker: Verter.state = 'Failure' or P2P.state = 'Failure'
 */
create or replace view v_all_passing_checks as (
		select Checks.ID as Checks_ID,
			Checks.Date as Checks_Date,
			Checks.Peer as Checked,
			P2P.CheckingPeer as Checking,
			Checks.Task as Task,
			P2P.State as P2P_state,
			Verter.State as Verter_state,
			(case
				when Verter.state = 'Failure' or P2P.state = 'Failure' then
					'F'
				end
			) as resume_f,
			(case
			when (Verter.state = 'Success' or P2P.state = 'Success'
					and Verter.state is null) then
				'S'
			end
			) as resume_s
		from Checks
			left join P2P on P2P."Check" = Checks.id
				and P2P.state != 'Start'
			left join Verter on Verter."Check" = Checks.id
				and Verter.state != 'Start'
		where P2P.CheckingPeer is not null
);


/*
 * Table with all peers, their friends and ids of row in 'Friends' table
 */
create or replace view v_peers_friends as (
	select nickname,
		id,
		(case
			when peer1 = nickname then peer2
			else peer1
			end
		) as friend
	from Peers
		join Friends on Friends.peer1 = Peers.nickname
			or Friends.peer2 = Peers.nickname
	order by 1
);


/*
 * Table with peers and all names of tasks' blocks which were started peer
 */
create or replace view v_peers_tasks_blocks as (
	select peer, 
		substring(task from '.+?(?=\d{1,2})') as task_block
	from Checks
	group by peer, substring(task from '.+?(?=\d{1,2})')
	order by peer
);


/*
 * Return peers (who started 'block'), their started blocks of tasks
 * and count of started blocks
 */
create or replace function fnc_is_peer_passed_block(block varchar)
	returns table(peer varchar, block_name varchar, count bigint) as
$$
begin
	return query(
		select v_ptb.peer,
			v_ptb.task_block::varchar,
			count(v_ptb.peer) over (partition by v_ptb.peer)
		from v_peers_tasks_blocks as v_ptb
			join v_peers_tasks_blocks as v_ptb1 on v_ptb1.peer = v_ptb.peer
				and v_ptb1.task_block = block
	);
end;
$$ language plpgsql;
