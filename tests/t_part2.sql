call fnc_print(' >>> part1 tests <<< ');

---------------------
--- prcdr_fnc_p2p ---
---------------------
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
    call fnc_print('test prcdr_fnc_p2p');

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

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


----------------------
-- prcdr_fnc_verter --
----------------------
begin;
do $$
declare
    count1 int;
    count2 int;
    rows_count int;
    peer1 varchar = 'username1';
    peer2 varchar = 'username2';
    peer1_check bigint;
    peer2_check bigint;
    verter_row Verter%rowtype;
begin
    call fnc_print('test prcdr_fnc_verter');

    insert into Peers values(peer1, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into Peers values(peer2, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    peer1_check = fnc_next_id('Checks');
    insert into Checks values(peer1_check, peer1, 'CPP1', '2024-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    peer2_check = fnc_next_id('Checks');
    insert into Checks values(peer2_check, peer2, 'CPP1', '2024-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Start', '12:12:12');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Success', '13:13:13');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    count1 = (select count(*) from Verter);
    call prcdr_fnc_verter(peer1, 'CPP1', 'Failure', '14:14:14');
    count2 = (select count(*) from Verter);
    assert (count1 + 1 = count2);

    select * into verter_row from Verter order by ID desc limit 1;
    assert(verter_row."Check" = peer1_check);
    assert(verter_row.state = 'Failure');
    assert(verter_row.time = '14:14:14');

    insert into P2P values(fnc_next_id('P2P'), peer2_check, peer1, 'Start', '15:15:15');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    count1 = (select count(*) from Verter);
    call prcdr_fnc_verter(peer2, 'CPP1', 'Failure', '16:16:16');
    count2 = (select count(*) from Verter);
    assert (count1 = count2);

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


---------------------------------------
-- trg_p2p_insert_transferred_points --
---------------------------------------
begin;
do $$
declare
    count1 int;
    count2 int;
    rows_count int;
    peer1 varchar = 'username1';
    peer2 varchar = 'username2';
    peer1_check bigint;
    tp_row TransferredPoints%rowtype;
begin
    call fnc_print('test trg_p2p_insert_transferred_points');

    insert into Peers values(peer1, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into Peers values(peer2, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    peer1_check = fnc_next_id('Checks');
    insert into Checks values(peer1_check, peer1, 'CPP1', '2024-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    count1 = (select count(*) from TransferredPoints);
    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Start', '12:12:12');
    count2 = (select count(*) from TransferredPoints);
    assert(count1 + 1 = count2);

    count1 = (select count(*) from TransferredPoints);
    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Success', '13:13:13');
    count2 = (select count(*) from TransferredPoints);
    assert(count1 = count2);

    select * into tp_row from TransferredPoints order by ID desc limit 1;
    assert(tp_row.checkedpeer = peer1);
    assert(tp_row.checkingpeer = peer2);
    assert(tp_row.pointsamount = 1);

    peer1_check = fnc_next_id('Checks');
    insert into Checks values(peer1_check, peer1, 'CPP2', '2024-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    count1 = (select count(*) from TransferredPoints);
    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Start', '14:14:14');
    count2 = (select count(*) from TransferredPoints);
    assert(count1 = count2);

    select * into tp_row from TransferredPoints order by ID desc limit 1;
    assert(tp_row.checkedpeer = peer1);
    assert(tp_row.checkingpeer = peer2);
    assert(tp_row.pointsamount = 2);

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------
-- trg_xp_check_insert --
-------------------------
begin;
do $$
declare
    rows_count int;
    peer1 varchar = 'username1';
    peer2 varchar = 'username2';
    peer1_check bigint;
begin
    call fnc_print('test trg_xp_check_insert');

    insert into Peers values(peer1, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into Peers values(peer2, '2000-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    peer1_check = fnc_next_id('Checks');
    insert into Checks values(peer1_check, peer1, 'CPP1', '2024-01-01');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Start', '12:12:12');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into XP values(fnc_next_id('XP'), peer1_check, 299);
    get diagnostics rows_count = row_count;
    assert (rows_count = 0);

    insert into P2P values(fnc_next_id('P2P'), peer1_check, peer2, 'Success', '13:13:13');
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    insert into XP values(fnc_next_id('XP'), peer1_check, 100500);
    get diagnostics rows_count = row_count;
    assert (rows_count = 0);

    insert into XP values(fnc_next_id('XP'), peer1_check, 301);
    get diagnostics rows_count = row_count;
    assert (rows_count = 0);

    insert into XP values(fnc_next_id('XP'), peer1_check, 299);
    get diagnostics rows_count = row_count;
    assert (rows_count = 1);

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;
