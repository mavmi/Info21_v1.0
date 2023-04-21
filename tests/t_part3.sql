call fnc_print(' >>> part3 tests <<< ');

---------------------------------------
--- fnc_readable_transferred_points ---
---------------------------------------
begin;
do $$
declare
    points int;
begin
    call fnc_print('test fnc_readable_transferred_points');

    delete from TransferredPoints;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 123);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 11);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 11);

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username3', 321);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username3', 0);

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 0);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 2);

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username3', 'username2', 100);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username3', 'username2', 101);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username3', 'username2', 102);

    select PointsAmount into points
    from fnc_readable_transferred_points()
    where Peer1 = 'username1' and Peer2 = 'username2';
    assert (points = 125);

    select PointsAmount into points
    from fnc_readable_transferred_points()
    where Peer1 = 'username1' and Peer2 = 'username3';
    assert (points = 323);

    select PointsAmount into points
    from fnc_readable_transferred_points()
    where Peer1 = 'username2' and Peer2 = 'username3';
    assert (points = -100);

    select PointsAmount into points
    from fnc_readable_transferred_points()
    where Peer1 = 'username3' and Peer2 = 'username2';
    assert (points = 100);

    assert((select count(*) from fnc_readable_transferred_points()) = 3);

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------------
--- fnc_successfully_passed_tasks ---
-------------------------------------
begin;
do $$
declare
    check1 bigint;
    check2 bigint;
    peer varchar;
    task varchar;
    xp int;
    size int = (select count(*) from fnc_successfully_passed_tasks());
begin
    call fnc_print('test fnc_successfully_passed_tasks');

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    check1 = fnc_next_id('Checks');
    insert into Checks values(check1, 'username1', 'CPP1', '2025-01-01');
    insert into P2P values(fnc_next_id('P2P'), check1, 'username3', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check1, 'username3', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check1, 300);

    select
        fnc_successfully_passed_tasks.Peer,
        fnc_successfully_passed_tasks.Task,
        fnc_successfully_passed_tasks.XP
    into
        peer,
        task,
        xp
    from fnc_successfully_passed_tasks()
    where fnc_successfully_passed_tasks.Peer = 'username1';
    assert(peer = 'username1');
    assert(task = 'CPP1');
    assert(xp = 300);
    assert((select count(*) from fnc_successfully_passed_tasks()) = size + 1);

    check2 = fnc_next_id('Checks');
    insert into Checks values(check2, 'username2', 'SQL1', '2025-01-01');
    insert into P2P values(fnc_next_id('P2P'), check2, 'username3', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check2, 'username3', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check2, 1500);

    select
        fnc_successfully_passed_tasks.Peer,
        fnc_successfully_passed_tasks.Task,
        fnc_successfully_passed_tasks.XP
    into
        peer,
        task,
        xp
    from fnc_successfully_passed_tasks()
    where fnc_successfully_passed_tasks.Peer = 'username2';
    assert(peer = 'username2');
    assert(task = 'SQL1');
    assert(xp = 1500);
    assert((select count(*) from fnc_successfully_passed_tasks()) = size + 2);

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-----------------------------------
--- fnc_hold_day_in_campus_list ---
-----------------------------------
begin;
do $$
declare
    peer varchar;
begin
    call fnc_print('test fnc_hold_day_in_campus_list');

    delete from TimeTracking;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-01', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-01', '23:59:58', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-02', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-02', '23:59:59', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-03', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-04', '00:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-05', '12:53:21', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-05', '21:01:31', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-06', '13:22:13', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-06', '16:21:53', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', '2024-01-07', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', '2024-01-07', '23:59:59', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-08', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-08', '23:59:59', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', '2024-01-08', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', '2024-01-08', '23:59:59', 2);

    select fnc_hold_day_in_campus_list."Peer" into peer from fnc_hold_day_in_campus_list('2024-01-01');
    assert(peer is null);

    select fnc_hold_day_in_campus_list."Peer" into peer from fnc_hold_day_in_campus_list('2024-01-02');
    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-02')) = 1);
    assert(peer = 'username1');

    select fnc_hold_day_in_campus_list."Peer" into peer from fnc_hold_day_in_campus_list('2024-01-03');
    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-03')) = 1);
    assert(peer = 'username1');

    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-04')) = 0);
    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-05')) = 0);
    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-06')) = 0);

    select fnc_hold_day_in_campus_list."Peer" into peer from fnc_hold_day_in_campus_list('2024-01-07');
    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-07')) = 1);
    assert(peer = 'username3');

    assert((select count(*) from fnc_hold_day_in_campus_list('2024-01-08')) = 2);

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------------
--- prcdr_passed_state_percentage ---
-------------------------------------
begin;
do $$
declare
    percentage double precision;
    ref refcursor := 'ref';
    check_id bigint;
begin
    call fnc_print('test prcdr_passed_state_percentage');

    truncate P2P cascade;
    truncate Checks cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 0);
    close ref;

    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Start', '12:12:12');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 0);
    close ref;

    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Success', '12:12:12');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 100);
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Failure', '12:12:12');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 50);
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Failure', '12:12:12');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 33);
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Failure', '12:12:12');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 25);
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username3', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '12:12:12');
    call prcdr_passed_state_percentage(ref);
    fetch ref into percentage;
    assert(percentage = 40);
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


--------------------------
--- prcdr_total_points ---
--------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_total_points');

    truncate TransferredPoints cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    call prcdr_total_points(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username1', 1);

    call prcdr_total_points(ref);
    for i in 1..4 loop
        fetch ref into rec;
        exit when not found;
        if (i = 4) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.PointsChange != 3 and i != 1) then
            assert(false);
        elseif (rec.Peer = 'username2' and rec.PointsChange != 0 and i != 2) then
            assert(false);
        elseif (rec.Peer = 'username3' and rec.PointsChange != -3 and i != 3) then
            assert(false);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------------
--- prcdr_totall_points_from_func ---
-------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_totall_points_from_func');

    truncate TransferredPoints cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    call prcdr_totall_points_from_func(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username2', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username1', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username3', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'username2', 'username1', 1);

    call prcdr_totall_points_from_func(ref);
    for i in 1..4 loop
        fetch ref into rec;
        exit when not found;
        if (i = 4) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.PointsChange != 3 and i != 1) then
            assert(false);
        elseif (rec.Peer = 'username2' and rec.PointsChange != 0 and i != 2) then
            assert(false);
        elseif (rec.Peer = 'username3' and rec.PointsChange != -3 and i != 3) then
            assert(false);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------------
--- prcdr_frequently_checked_task ---
-------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_frequently_checked_task');

    truncate Checks cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');

    call prcdr_frequently_checked_task(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'CPP1', '2024-01-01');
    insert into Checks values(fnc_next_id('Checks'), 'username2', 'CPP1', '2024-01-01');
    insert into Checks values(fnc_next_id('Checks'), 'username3', 'SQL1', '2024-01-01');

    call prcdr_frequently_checked_task(ref);
    loop
        fetch ref into rec;
        if (rec.Day != '2024-01-01' and rec.Task != 'CPP1') then
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'CPP1', '2024-01-01');
    insert into Checks values(fnc_next_id('Checks'), 'username2', 'CPP1', '2024-01-01');
    insert into Checks values(fnc_next_id('Checks'), 'username3', 'SQL1', '2024-01-01');
    insert into Checks values(fnc_next_id('Checks'), 'username3', 'SQL1', '2024-01-01');

    call prcdr_frequently_checked_task(ref);
    loop
        fetch ref into rec;
        if (rec.Day != '2024-01-01' and rec.Task != 'CPP1') then
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'CPP1', '2024-01-02');
    insert into Checks values(fnc_next_id('Checks'), 'username2', 'A1', '2024-01-02');
    insert into Checks values(fnc_next_id('Checks'), 'username3', 'A1', '2024-01-02');

    call prcdr_frequently_checked_task(ref);
    for i in 1..3 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Day = '2024-01-01' and rec.Task != 'CPP1') then
            assert(false);
        elseif (rec.Day = '2024-01-02' and rec.Task != 'A1') then
            assert(false);
        elseif (i = 3) then
            assert(false);
        end if;
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'SQL1', '2024-01-03');
    insert into Checks values(fnc_next_id('Checks'), 'username2', 'DO1', '2024-01-03');
    insert into Checks values(fnc_next_id('Checks'), 'username3', 'SQL1', '2024-01-03');

    call prcdr_frequently_checked_task(ref);
    for i in 1..4 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Day = '2024-01-01' and rec.Task != 'CPP1') then
            assert(false);
        elseif (rec.Day = '2024-01-02' and rec.Task != 'A1') then
            assert(false);
        elseif (rec.Day = '2024-01-03' and rec.Task != 'SQL1') then
            assert(false);
        elseif (i = 4) then
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------------
--- prcdr_checking_time_duration ---
-------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_checking_time_duration');

    truncate P2P cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:00:00');

    call prcdr_checking_time_duration(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_checking_time_duration(ref);
    loop
        fetch ref into rec;
        if (rec.CheckDuration != '00:12:12'::time) then
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:13:14');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Failure', '13:14:15');

    call prcdr_checking_time_duration(ref);
    loop
        fetch ref into rec;
        if (rec.CheckDuration != '01:01:01'::time) then
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------
--- prcdr_passed_task_block ---
-------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_passed_task_block');

    truncate P2P cascade;
    truncate Checks cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');

    call prcdr_passed_task_block(ref, 'CPP');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_passed_task_block(ref, 'CPP');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP3', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP4', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP5', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Failure', '12:12:12');

    call prcdr_passed_task_block(ref, 'CPP');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP5', '2024-01-12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_passed_task_block(ref, 'CPP');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        if (i = 1 and rec.Peer = 'username1' and rec.Day = '2024-01-12') then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'SQL1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '12:12:12');

    call prcdr_passed_task_block(ref, 'SQL');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'SQL2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'SQL3', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Failure', '12:12:12');

    call prcdr_passed_task_block(ref, 'SQL');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'SQL3', '2024-02-03');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '12:12:12');

    call prcdr_passed_task_block(ref, 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        if (i = 1 and rec.Peer = 'username2' and rec.Day = '2024-02-03') then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


------------------------------
--- prcdr_recommended_peer ---
------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_recommended_peer');

    truncate Friends cascade;
    truncate Recommendations cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');
    insert into Peers values('username5', '2000-01-01');
    insert into Peers values('username6', '2000-01-01');

    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username2');
    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username3');

    call prcdr_recommended_peer(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Recommendations values(fnc_next_id('Recommendations'), 'username2', 'username4');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'username3', 'username4');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'username3', 'username5');

    call prcdr_recommended_peer(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        if (rec.RecommendedPeer = 'username4') then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    insert into Recommendations values(fnc_next_id('Recommendations'), 'username2', 'username5');

    call prcdr_recommended_peer(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        if (rec.RecommendedPeer = 'username4') then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username6');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'username6', 'username5');

    call prcdr_recommended_peer(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        if (rec.RecommendedPeer = 'username5') then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


------------------------------------
--- prcdr_percenge_started_block ---
------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_percenge_started_block');

    truncate Checks cascade;
    truncate P2P cascade;
    truncate Peers cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');
    insert into Peers values('username5', '2000-01-01');

    call prcdr_percenge_started_block(ref, 'CPP', 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        assert(rec.StartedBlock1 = 0);
        assert(rec.StartedBlock2 = 0);
        assert(rec.StartedBothBlocks = 0);
        assert(rec.DidntStartAnyBlock = 100);

        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');

    call prcdr_percenge_started_block(ref, 'CPP', 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        assert(rec.StartedBlock1 = 20);
        assert(rec.StartedBlock2 = 0);
        assert(rec.StartedBothBlocks = 0);
        assert(rec.DidntStartAnyBlock = 80);
        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP3', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP4', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP5', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Failure', '12:12:12');

    call prcdr_percenge_started_block(ref, 'CPP', 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        assert(rec.StartedBlock1 = 20);
        assert(rec.StartedBlock2 = 0);
        assert(rec.StartedBothBlocks = 0);
        assert(rec.DidntStartAnyBlock = 80);
        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP5', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_percenge_started_block(ref, 'CPP', 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        assert(rec.StartedBlock1 = 20);
        assert(rec.StartedBlock2 = 0);
        assert(rec.StartedBothBlocks = 0);
        assert(rec.DidntStartAnyBlock = 80);
        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'SQL1', '2024-01-01');

    call prcdr_percenge_started_block(ref, 'CPP', 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        assert(rec.StartedBlock1 = 20);
        assert(rec.StartedBlock2 = 20);
        assert(rec.StartedBothBlocks = 0);
        assert(rec.DidntStartAnyBlock = 60);
        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'SQL1', '2024-01-01');
    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username3', 'SQL1', '2024-01-01');

    call prcdr_percenge_started_block(ref, 'CPP', 'SQL');
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        assert(rec.StartedBlock1 = 20);
        assert(rec.StartedBlock2 = 60);
        assert(rec.StartedBothBlocks = 20);
        assert(rec.DidntStartAnyBlock = 40);
        if (i = 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


/*
do
$insert_current_peers_visities$
begin
	/* Yesterday visities */

	-- minuse 1 day & 8:03
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '1 day 483 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 483 minute')::time,
		1
	);
	-- minuse 1 day & 8:00
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '1 day 300 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 300 minute')::time,
		2
	);

	-- minuse 1 day & 5:13
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Gabriel',
		(LOCALTIMESTAMP - interval '1 day 313 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 313 minute')::time,
		1
	);
	-- minuse 1 day & 3:04
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Gabriel',
		(LOCALTIMESTAMP - interval '1 day 184 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 184 minute')::time,
		2
	);

	-- minuse 1 day & 4:17
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '1 day 257 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 257 minute')::time,
		1
	);
	-- minuse 1 day & 0:30
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '1 day 30 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 30 minute')::time,
		2
	);

	-- minuse 1 day & 3:39
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Luisi',
		(LOCALTIMESTAMP - interval '1 day 219 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 219 minute')::time,
		1
	);
	-- minuse 1 day & 0:30
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Luisi',
		(LOCALTIMESTAMP - interval '1 day 30 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 30 minute')::time,
		2
	);

	/* Today visities */

	-- minuse 15:03
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '903 minute')::date,
		(LOCALTIMESTAMP(0) - interval '903 minute')::time,
		1
	);
	-- minuse 8:00
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '300 minute')::date,
		(LOCALTIMESTAMP(0) - interval '300 minute')::time,
		2
	);


	-- minuse 5:13
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '313 minute')::date,
		(LOCALTIMESTAMP(0) - interval '313 minute')::time,
		1
	);
	-- minuse 3:04
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '184 minute')::date,
		(LOCALTIMESTAMP(0) - interval '184 minute')::time,
		2
	);

	-- minuse 4:17
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '257 minute')::date,
		(LOCALTIMESTAMP(0) - interval '257 minute')::time,
		1
	);
	-- minuse 0:30
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '30 minute')::date,
		(LOCALTIMESTAMP(0) - interval '30 minute')::time,
		2
	);

	-- minuse 6:37
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '397 minute')::date,
		(LOCALTIMESTAMP(0) - interval '397 minute')::time,
		1
	);
	-- minuse 3:21
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '201 minute')::date,
		(LOCALTIMESTAMP(0) - interval '201 minute')::time,
		2
	);

	-- minuse 6:34 (still at school)
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Luisi',
		(LOCALTIMESTAMP - interval '700 minute')::date,
		(LOCALTIMESTAMP(0) - interval '700 minute')::time,
		1
	);
end
$insert_current_peers_visities$;
*/
