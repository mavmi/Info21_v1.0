--------------------------
--- test prcdr_fnc_p2p ---
--------------------------
begin;
do $$
declare
    p2p_count int := (select count(*) from P2P);
    checks_count int := (select count(*) from Checks);
    p2p_max_id int := (select max(ID) from P2P);
    checks_max_id int := (select max(ID) from Checks);
    p2p_line P2P%rowtype;
    checks_line Checks%rowtype;
    rows_count int;
    checked_peer varchar = 'username1';
    checking_peer varchar = 'username2';
begin
    insert into Peers values(checked_peer, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into Peers values(checking_peer, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    call prcdr_fnc_p2p(checked_peer, checking_peer, 'CPP2', 'Start', '12:12:12');
    assert((select count(*) from P2P) = p2p_count);
    assert((select count(*) from Checks) = checks_count);

    call prcdr_fnc_p2p(checked_peer, checking_peer, 'CPP2', 'Failure', '12:12:12');
    assert((select count(*) from P2P) = p2p_count);
    assert((select count(*) from Checks) = checks_count);

    call prcdr_fnc_p2p(checked_peer, checking_peer, 'CPP1', 'Start', '12:12:12');
    assert((select count(*) from P2P) = p2p_count + 1);
    assert((select count(*) from Checks) = checks_count + 1);

    select * into p2p_line from P2P order by ID desc limit 1;
    assert(p2p_line.id = p2p_max_id + 1);
    assert(p2p_line."Check" = checks_max_id + 1);
    assert(p2p_line.checkingpeer = checking_peer);
    assert(p2p_line.state = 'Start');
    assert(p2p_line.time = '12:12:12');

    select * into checks_line from Checks order by ID desc limit 1;
    assert(checks_line.id = checks_max_id + 1);
    assert(checks_line.peer = checked_peer);
    assert(checks_line.task = 'CPP1');
    assert(checks_line.date = current_date);

    call prcdr_fnc_p2p(checked_peer, checking_peer, 'CPP1', 'Success', '13:13:13');
    assert((select count(*) from P2P) = p2p_count + 2);
    assert((select count(*) from Checks) = checks_count + 1);

    select * into p2p_line from P2P order by ID desc limit 1;
    assert(p2p_line.id = p2p_max_id + 2);
    assert(p2p_line."Check" = checks_max_id + 1);
    assert(p2p_line.checkingpeer = checking_peer);
    assert(p2p_line.state = 'Success');
    assert(p2p_line.time = '13:13:13');
end;
$$ language plpgsql;
rollback;
