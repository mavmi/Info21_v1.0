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
);


/*
 * Return next ID for 'table_name' table
 */
create or replace function fnc_next_id(table_name varchar, out id bigint) as
$$
begin
	execute format('select coalesce(max(id) + 1, 1) from %s', table_name)
	into id;
end;
$$ language plpgsql;
