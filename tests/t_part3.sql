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


------------------------------------
--- prcdr_greates_friends_number ---
------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_greates_friends_number');

    truncate Peers cascade;
    truncate Friends cascade;

    call prcdr_greates_friends_number(ref, 10);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');
    insert into Peers values('username5', '2000-01-01');

    call prcdr_greates_friends_number(ref, 10);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username2');

    call prcdr_greates_friends_number(ref, 10);
    for i in 1..6 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Peer = 'username1' and rec.FriendsCount = 1) then
            assert(true);
        elseif (rec.Peer != 'username1' and rec.FriendsCount = 0) then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 6) then
            assert(false);
        end if;
    end loop;
    close ref;

    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username3');
    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username4');
    insert into Friends values(fnc_next_id('Friends'), 'username1', 'username5');
    insert into Friends values(fnc_next_id('Friends'), 'username2', 'username3');
    insert into Friends values(fnc_next_id('Friends'), 'username2', 'username4');
    insert into Friends values(fnc_next_id('Friends'), 'username3', 'username4');

    call prcdr_greates_friends_number(ref, 10);
    for i in 1..6 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Peer = 'username1' and rec.FriendsCount = 4) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.FriendsCount = 3) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.FriendsCount = 3) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.FriendsCount = 3) then
            assert(true);
        elseif (rec.Peer = 'username5' and rec.FriendsCount = 1) then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 6) then
            assert(false);
        end if;
    end loop;
    close ref;

    call prcdr_greates_friends_number(ref, 4);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Peer = 'username1' and rec.FriendsCount = 4) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.FriendsCount = 3) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.FriendsCount = 3) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.FriendsCount = 3) then
            assert(true);
        else
            assert(false);
        end if;

        if (i = 5) then
            assert(false);
        end if;
    end loop;
    close ref;

    call prcdr_greates_friends_number(ref, 1);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Peer = 'username1' and rec.FriendsCount = 4) then
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


--------------------------------
--- prcdr_passed_on_birthday ---
--------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_passed_on_birthday');

    truncate Verter cascade;
    truncate P2P cascade;
    truncate Checks cascade;
    truncate Peers cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-02');
    insert into Peers values('username3', '2000-01-03');
    insert into Peers values('username4', '2000-01-04');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 0);
        assert(rec.UnsuccessfulChecks = 0);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-03-12');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 0);
        assert(rec.UnsuccessfulChecks = 0);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-03-12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 0);
        assert(rec.UnsuccessfulChecks = 0);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Failure', '12:12:12');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 0);
        assert(rec.UnsuccessfulChecks = 100);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 50);
        assert(rec.UnsuccessfulChecks = 50);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'CPP1', '2024-01-02');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Failure', '12:12:12');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 33);
        assert(rec.UnsuccessfulChecks = 67);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username3', 'CPP1', '2024-01-03');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '12:12:12');

    call prcdr_passed_on_birthday(ref);
    loop
        fetch ref into rec;

        assert(rec.SuccessfulChecks = 50);
        assert(rec.UnsuccessfulChecks = 50);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


----------------------------------
--- prcdr_total_peer_xp_amount ---
----------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_total_peer_xp_amount');

    truncate Peers cascade;
    truncate XP cascade;
    truncate Checks cascade;
    truncate Verter cascade;
    truncate P2P cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_total_peer_xp_amount(ref);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (i = 5) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.XP = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 299);

    call prcdr_total_peer_xp_amount(ref);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (i = 5) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 299) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.XP = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 300);

    call prcdr_total_peer_xp_amount(ref);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (i = 5) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 300) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.XP = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 400);

    call prcdr_total_peer_xp_amount(ref);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (i = 5) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 700) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.XP = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'SQL1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 1500);

    call prcdr_total_peer_xp_amount(ref);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (i = 5) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 2200) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.XP = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username3', 'DO1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 250);

    call prcdr_total_peer_xp_amount(ref);
    for i in 1..5 loop
        fetch ref into rec;
        exit when not found;

        if (i = 5) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 2200) then
            assert(true);
        elseif (rec.Peer = 'username2' and rec.XP = 0) then
            assert(true);
        elseif (rec.Peer = 'username3' and rec.XP = 250) then
            assert(true);
        elseif (rec.Peer = 'username4' and rec.XP = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


----------------------------
--- prcdr_did_peer_tasks ---
----------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_did_peer_tasks');

    truncate Peers cascade;
    truncate Checks cascade;
    truncate P2P cascade;
    truncate Verter cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_did_peer_tasks(ref, 'CPP1', 'SQL1', 'DO1');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'CPP1', '2024-01-01');

    call prcdr_did_peer_tasks(ref, 'CPP1', 'SQL1', 'DO1');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'SQL1', '2024-01-01');

    call prcdr_did_peer_tasks(ref, 'CPP1', 'SQL1', 'DO1');
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username1', 'DO1', '2024-01-01');

    call prcdr_did_peer_tasks(ref, 'CPP1', 'SQL1', 'DO1');
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Checks values(fnc_next_id('Checks'), 'username3', 'SQL1', '2024-01-01');
    insert into Checks values(fnc_next_id('Checks'), 'username3', 'CPP1', '2024-01-01');

    call prcdr_did_peer_tasks(ref, 'CPP1', 'SQL1', 'DO1');
    loop
        fetch ref into rec;

        if (rec.Peer = 'username3') then
            assert(true);
        else
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


-----------------------------
--- prcdr_preceding_tasks ---
-----------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_preceding_tasks');

    call prcdr_preceding_tasks(ref);
    for i in 1..11 loop
        fetch ref into rec;
        exit when not found;

        if (rec.Task = 'DO1' and rec.PrevCount != 0) then
            assert(false);
        elseif (rec.Task = 'DO2' and rec.PrevCount != 2) then
            assert(false);
        elseif (rec.Task = 'DO3' and rec.PrevCount != 3) then
            assert(false);
        elseif (rec.Task = 'DO4' and rec.PrevCount != 4) then
            assert(false);
        elseif (rec.Task = 'DO5' and rec.PrevCount != 5) then
            assert(false);
        elseif (rec.Task = 'DO6' and rec.PrevCount != 6) then
            assert(false);
        elseif (rec.Task = 'CPP1' and rec.PrevCount != 0) then
            assert(false);
        elseif (rec.Task = 'CPP2' and rec.PrevCount != 1) then
            assert(false);
        elseif (rec.Task = 'CPP3' and rec.PrevCount != 2) then
            assert(false);
        elseif (rec.Task = 'CPP4' and rec.PrevCount != 3) then
            assert(false);
        elseif (rec.Task = 'CPP5' and rec.PrevCount != 4) then
            assert(false);
        elseif (rec.Task = 'A1' and rec.PrevCount != 0) then
            assert(false);
        elseif (rec.Task = 'A2' and rec.PrevCount != 1) then
            assert(false);
        elseif (rec.Task = 'A3' and rec.PrevCount != 2) then
            assert(false);
        elseif (rec.Task = 'A4' and rec.PrevCount != 3) then
            assert(false);
        elseif (rec.Task = 'A5' and rec.PrevCount != 4) then
            assert(false);
        elseif (rec.Task = 'A6' and rec.PrevCount != 5) then
            assert(false);
        elseif (rec.Task = 'A7' and rec.PrevCount != 6) then
            assert(false);
        elseif (rec.Task = 'A8' and rec.PrevCount != 7) then
            assert(false);
        elseif (rec.Task = 'SQL1' and rec.PrevCount != 0) then
            assert(false);
        elseif (rec.Task = 'SQL2' and rec.PrevCount != 1) then
            assert(false);
        elseif (rec.Task = 'SQL3' and rec.PrevCount != 2) then
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------
--- prcdr_checks_lucky_days ---
-------------------------------
begin;
do $$
    declare
        ref refcursor := 'ref';
        rec record;
        check_id bigint;
    begin
        call fnc_print('test prcdr_checks_lucky_days');

        truncate Checks cascade;
        truncate Verter cascade;
        truncate P2P cascade;

        insert into Peers values('username1', '2000-01-01');
        insert into Peers values('username2', '2000-01-01');

        call prcdr_checks_lucky_days(ref, 1);
        loop
            fetch ref into rec;
            exit when not found;
            assert(false);
        end loop;
        close ref;

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-01');

        call prcdr_checks_lucky_days(ref, 1);
        loop
            fetch ref into rec;
            exit when not found;
            assert(false);
        end loop;
        close ref;

        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
        insert into XP values(fnc_next_id('XP'), check_id, 50);

        call prcdr_checks_lucky_days(ref, 1);
        loop
            fetch ref into rec;
            exit when not found;
            assert(false);
        end loop;
        close ref;

        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
        insert into XP values(fnc_next_id('XP'), check_id, 300);

        call prcdr_checks_lucky_days(ref, 1);
        for i in 1..2 loop
                fetch ref into rec;
                exit when not found;

                if (i = 2) then
                    assert(false);
                end if;

                if (rec.checks_date = '2024-01-01') then
                    assert(true);
                else
                    assert(false);
                end if;
            end loop;
        close ref;

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-02');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '13:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'CPP1', '2024-01-02');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '14:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '15:12:12');

        call prcdr_checks_lucky_days(ref, 2);
        for i in 1..2 loop
                fetch ref into rec;
                exit when not found;

                if (i = 2) then
                    assert(false);
                end if;

                if (rec.checks_date = '2024-01-02') then
                    assert(true);
                else
                    assert(false);
                end if;
            end loop;
        close ref;

        call prcdr_checks_lucky_days(ref, 3);
        loop
            fetch ref into rec;
            exit when not found;
            assert(false);
        end loop;
        close ref;

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'CPP1', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '13:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'CPP1', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '14:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '15:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '16:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '17:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'CPP2', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '18:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Failure', '19:12:12');

        call prcdr_checks_lucky_days(ref, 3);
        for i in 1..2 loop
                fetch ref into rec;
                exit when not found;

                if (i = 2) then
                    assert(false);
                end if;

                if (rec.checks_date = '2024-01-03') then
                    assert(true);
                else
                    assert(false);
                end if;
            end loop;
        close ref;

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'SQL1', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '13:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'SQL1', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '14:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '15:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'SQL2', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '16:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Failure', '17:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'SQL2', '2024-01-03');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '18:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '19:12:12');

        call prcdr_checks_lucky_days(ref, 3);
        loop
            fetch ref into rec;
            exit when not found;
            assert(false);
        end loop;
        close ref;

        truncate Checks cascade;
        truncate Verter cascade;
        truncate P2P cascade;

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'SQL1', '2024-01-01');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '13:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'SQL1', '2024-01-01');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '14:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '15:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username1', 'SQL2', '2024-01-02');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '16:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Failure', '17:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'SQL2', '2024-01-02');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '18:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '19:12:12');

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, 'username2', 'SQL3', '2024-01-02');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Start', '20:12:12');
        insert into P2P values(fnc_next_id('P2P'), check_id, 'username1', 'Success', '21:12:12');
        insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '22:12:12');
        insert into Verter values(fnc_next_id('Verter'), check_id, 'Failure', '23:12:12');

        call prcdr_checks_lucky_days(ref, 1);
        for i in 1..3 loop
                fetch ref into rec;
                exit when not found;

                if (i = 3) then
                    assert(false);
                end if;

                if (rec.checks_date = '2024-01-01' or rec.checks_date = '2024-01-02') then
                    assert(true);
                else
                    assert(false);
                end if;
            end loop;
        close ref;

        call prcdr_checks_lucky_days(ref, 2);
        for i in 1..3 loop
                fetch ref into rec;
                exit when not found;

                if (i = 3) then
                    assert(false);
                end if;

                if (rec.checks_date = '2024-01-01' or rec.checks_date = '2024-01-02') then
                    assert(true);
                else
                    assert(false);
                end if;
            end loop;
        close ref;

        call prcdr_checks_lucky_days(ref, 3);
        loop
            fetch ref into rec;
            exit when not found;
            assert(false);
        end loop;
        close ref;

        call fnc_print('ok');
    end;
$$ language plpgsql;
rollback;


---------------------------------------------------
--- prcdr_peer_with_highest_passed_tasks_number ---
---------------------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_peer_with_highest_passed_tasks_number');

    truncate Checks cascade;
    truncate P2P cascade;
    truncate Verter cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_peer_with_highest_passed_tasks_number(ref);
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

    call prcdr_peer_with_highest_passed_tasks_number(ref);
    for i in 1..2 loop
        fetch ref into rec;

        assert(rec.Peer = 'username1');
        assert(rec.CompletedNumber = 1);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Failure', '12:12:12');

    call prcdr_peer_with_highest_passed_tasks_number(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '12:12:12');
    insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'SQL1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'DO1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_peer_with_highest_passed_tasks_number(ref);
    for i in 1..2 loop
        fetch ref into rec;

        assert(rec.Peer = 'username1');
        assert(rec.CompletedNumber = 4);

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'SQL1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'DO1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');

    call prcdr_peer_with_highest_passed_tasks_number(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.CompletedNumber = 4) then
            assert(true);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


----------------------------------
--- prcdr_peer_with_highest_xp ---
----------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
    check_id bigint;
begin
    call fnc_print('test prcdr_peer_with_highest_xp');

    truncate Checks cascade;
    truncate P2P cascade;
    truncate Verter cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_peer_with_highest_xp(ref);
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
    insert into XP values(fnc_next_id('XP'), check_id, 300);

    call prcdr_peer_with_highest_xp(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 300) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 400);

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'CPP3', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 300);

    call prcdr_peer_with_highest_xp(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 1000) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'CPP1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 200);

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username2', 'CPP2', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 200);

    call prcdr_peer_with_highest_xp(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 1000) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    check_id = fnc_next_id('Checks');
    insert into Checks values(check_id, 'username1', 'SQL1', '2024-01-01');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Start', '12:12:12');
    insert into P2P values(fnc_next_id('P2P'), check_id, 'username2', 'Success', '12:12:12');
    insert into XP values(fnc_next_id('XP'), check_id, 1500);

    call prcdr_peer_with_highest_xp(ref);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' and rec.XP = 2500) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


----------------------------------------
--- prcdr_longest_campus_visit_today ---
----------------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_longest_campus_visit_today');

    truncate TimeTracking cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_longest_campus_visit_today(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '13:00:00', 2);

    call prcdr_longest_campus_visit_today(ref);
    loop
        fetch ref into rec;
        assert(rec.Peer = 'username1');
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date, '00:00:00', 1);

    call prcdr_longest_campus_visit_today(ref);
    loop
        fetch ref into rec;
        assert(rec.Peer = 'username2');
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date, '00:30:00', 2);

    call prcdr_longest_campus_visit_today(ref);
    loop
        fetch ref into rec;
        assert(rec.Peer = 'username1');
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', current_date, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', current_date, '18:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date, '15:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date, '15:10:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date, '18:10:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date, '18:20:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date, '21:20:00', 2);

    call prcdr_longest_campus_visit_today(ref);
    loop
        fetch ref into rec;
        assert(rec.Peer = 'username4');
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------
--- prcdr_came_before ---
-------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_came_before');

    truncate timetracking cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_came_before(ref, '12:00:00', 1);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-01', '11:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-01', '12:00:00', 2);

    call prcdr_came_before(ref, '12:00:00', 1);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1') then
            assert(true);
        end if;
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-02', '11:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-02', '12:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-03', '11:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-03', '12:00:00', 2);

    call prcdr_came_before(ref, '12:00:00', 1);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1') then
            assert(true);
        end if;
    end loop;
    close ref;

    call prcdr_came_before(ref, '12:00:00', 2);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1') then
            assert(true);
        end if;
    end loop;
    close ref;

    call prcdr_came_before(ref, '12:00:00', 3);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1') then
            assert(true);
        end if;
    end loop;
    close ref;

    call prcdr_came_before(ref, '12:00:00', 4);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-04', '11:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-04', '12:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-05', '11:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-05', '12:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-04', '15:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2024-01-04', '17:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-05', '15:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', '2024-01-05', '17:00:00', 2);

    call prcdr_came_before(ref, '12:00:00', 1);
    for i in 1..3 loop
        fetch ref into rec;
        exit when not found;
        if (i = 3) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' or rec.Peer = 'username2') then
            assert(true);
        end if;
    end loop;
    close ref;

    call prcdr_came_before(ref, '12:00:00', 2);
    for i in 1..3 loop
        fetch ref into rec;
        exit when not found;
        if (i = 3) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' or rec.Peer = 'username2') then
            assert(true);
        end if;
    end loop;
    close ref;

    call prcdr_came_before(ref, '12:00:00', 3);
    for i in 1..2 loop
        fetch ref into rec;
        exit when not found;
        if (i = 2) then
            assert(false);
        end if;

        if (rec.Peer = 'username1') then
            assert(true);
        end if;
    end loop;
    close ref;

    call prcdr_came_before(ref, '12:00:00', 4);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


------------------------------
--- prcdr_left_during_time ---
------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_left_during_time');

    truncate TimeTracking cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_left_during_time(ref, 1, 10);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '3 days'::interval, '12:00:00', 1);

    call prcdr_left_during_time(ref, 0, 10);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '3 days'::interval, '13:00:00', 2);

    call prcdr_left_during_time(ref, 0, 10);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '2 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '2 days'::interval, '13:00:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '13:00:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '3 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '3 days'::interval, '13:00:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '2 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '2 days'::interval, '13:00:00', 2);

    call prcdr_left_during_time(ref, 0, 10);
    for i in 1..3 loop
        fetch ref into rec;
        exit when not found;
        if (i = 3) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' or rec.Peer = 'username2') then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call prcdr_left_during_time(ref, 1, 10);
    for i in 1..3 loop
        fetch ref into rec;
        exit when not found;
        if (i = 3) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' or rec.Peer = 'username2') then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call prcdr_left_during_time(ref, 2, 10);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    truncate TimeTracking cascade;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '10 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '10 days'::interval, '13:00:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '9 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '9 days'::interval, '13:00:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '8 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '8 days'::interval, '13:00:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '7 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '7 days'::interval, '13:00:00', 2);

    call prcdr_left_during_time(ref, 0, 10);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    call prcdr_left_during_time(ref, 0, 5);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-----------------------------
--- prcdr_who_come_laster ---
-----------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_who_come_laster');

    truncate TimeTracking cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_who_come_laster(ref);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '12:00:00', 1);

    call prcdr_who_come_laster(ref);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date, '13:00:00', 1);

    call prcdr_who_come_laster(ref);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username2') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '13:00:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '14:00:00', 1);

    call prcdr_who_come_laster(ref);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '15:00:00', 2);

    call prcdr_who_come_laster(ref);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
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


-----------------------------------
--- prcdr_who_come_back_in_time ---
-----------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_who_come_back_in_time');

    truncate TimeTracking cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-01-01');
    insert into Peers values('username4', '2000-01-01');

    call prcdr_who_come_back_in_time(ref, 21);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '12:10:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date, '13:30:00', 1);

    call prcdr_who_come_back_in_time(ref, 21);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    truncate TimeTracking cascade;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '2 days'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '2 days'::interval, '12:10:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '2 days'::interval, '13:30:00', 1);

    call prcdr_who_come_back_in_time(ref, 21);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    truncate TimeTracking cascade;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:10:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:20:00', 1);

    call prcdr_who_come_back_in_time(ref, 21);
    loop
        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:30:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '13:00:00', 1);

    call prcdr_who_come_back_in_time(ref, 21);
    loop
        fetch ref into rec;

        if (rec.Peer = 'username1') then
            assert(true);
        else
            assert(false);
        end if;

        fetch ref into rec;
        exit when not found;
        assert(false);
    end loop;
    close ref;

    truncate TimeTracking cascade;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '12:10:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', current_date - '1 day'::interval, '13:20:00', 1);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '1 day'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '1 day'::interval, '12:10:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username2', current_date - '1 day'::interval, '13:20:00', 1);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', current_date - '1 day'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', current_date - '1 day'::interval, '12:10:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date - '1 day'::interval, '12:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date - '1 day'::interval, '12:10:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date - '1 day'::interval, '12:20:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date - '1 day'::interval, '12:30:00', 2);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date - '1 day'::interval, '12:40:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', current_date - '1 day'::interval, '12:50:00', 2);

    call prcdr_who_come_back_in_time(ref, 21);
     for i in 1..3 loop
        fetch ref into rec;
        exit when not found;
        if (i = 3) then
            assert(false);
        end if;

        if (rec.Peer = 'username1' or rec.Peer = 'username2') then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-------------------------------
--- prcdr_early_in_birthday ---
-------------------------------
begin;
do $$
declare
    ref refcursor := 'ref';
    rec record;
begin
    call fnc_print('test prcdr_early_in_birthday');

    truncate TimeTracking cascade;

    insert into Peers values('username1', '2000-01-01');
    insert into Peers values('username2', '2000-01-01');
    insert into Peers values('username3', '2000-02-02');
    insert into Peers values('username4', '2000-02-02');

    call prcdr_early_in_birthday(ref);
    for i in 1..13 loop
        fetch ref into rec;
        exit when not found;
        if (i = 13) then
            assert(false);
        end if;

        if (rec.Month = 'January  ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'February ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'March    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'April    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'May      ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'June     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'July     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'August   ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'September' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'October  ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'November ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'December ' and rec.EarlyEntries = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2020-01-01', '10:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username1', '2020-01-01', '10:00:00', 2);

    call prcdr_early_in_birthday(ref);
    for i in 1..13 loop
        fetch ref into rec;
        exit when not found;
        if (i = 13) then
            assert(false);
        end if;

        if (rec.Month = 'January  ' and rec.EarlyEntries = 100) then
            assert(true);
        elseif (rec.Month = 'February ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'March    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'April    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'May      ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'June     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'July     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'August   ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'September' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'October  ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'November ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'December ' and rec.EarlyEntries = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', '2020-02-02', '10:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username3', '2020-02-02', '10:00:00', 2);

    call prcdr_early_in_birthday(ref);
    for i in 1..13 loop
        fetch ref into rec;
        exit when not found;
        if (i = 13) then
            assert(false);
        end if;

        if (rec.Month = 'January  ' and rec.EarlyEntries = 50) then
            assert(true);
        elseif (rec.Month = 'February ' and rec.EarlyEntries = 50) then
            assert(true);
        elseif (rec.Month = 'March    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'April    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'May      ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'June     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'July     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'August   ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'September' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'October  ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'November ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'December ' and rec.EarlyEntries = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', '2020-02-12', '10:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'username4', '2020-02-12', '10:00:00', 2);

    call prcdr_early_in_birthday(ref);
    for i in 1..13 loop
        fetch ref into rec;
        exit when not found;
        if (i = 13) then
            assert(false);
        end if;

        raise notice '%:%', rec.Month, rec.EarlyEntries;
        if (rec.Month = 'January  ' and rec.EarlyEntries = 33) then
            assert(true);
        elseif (rec.Month = 'February ' and rec.EarlyEntries = 67) then
            assert(true);
        elseif (rec.Month = 'March    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'April    ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'May      ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'June     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'July     ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'August   ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'September' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'October  ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'November ' and rec.EarlyEntries = 0) then
            assert(true);
        elseif (rec.Month = 'December ' and rec.EarlyEntries = 0) then
            assert(true);
        else
            assert(false);
        end if;
    end loop;
    close ref;

    call fnc_print('ok');
end;
$$ language plpgsql;
rollback;


-----------
-- print --
-----------
call fnc_print('fnc_readable_transferred_points');
select * from fnc_readable_transferred_points();

call fnc_print('fnc_successfully_passed_tasks');
select * from fnc_successfully_passed_tasks();

call fnc_print('fnc_hold_day_in_campus_list');
select * from fnc_hold_day_in_campus_list('2022-12-07');

begin;
call fnc_print('prcdr_passed_state_percentage');
call prcdr_passed_state_percentage('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_total_points');
call prcdr_total_points('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_totall_points_from_func');
call prcdr_totall_points_from_func('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_frequently_checked_task');
call prcdr_frequently_checked_task('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_checking_time_duration');
call prcdr_checking_time_duration('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_passed_task_block');
call prcdr_passed_task_block('ref', 'CPP');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_recommended_peer');
call prcdr_recommended_peer('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_percenge_started_block');
call prcdr_percenge_started_block('ref', 'CPP', 'SQL');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_greates_friends_number');
call prcdr_greates_friends_number('ref', 3);
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_passed_on_birthday');
call prcdr_passed_on_birthday('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_total_peer_xp_amount');
call prcdr_total_peer_xp_amount('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_did_peer_tasks');
call prcdr_did_peer_tasks('ref', 'CPP', 'SQL', 'DO');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_preceding_tasks');
call prcdr_preceding_tasks('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_checks_lucky_days');
call prcdr_checks_lucky_days('ref', 4);
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_peer_with_highest_passed_tasks_number');
call prcdr_peer_with_highest_passed_tasks_number('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_peer_with_highest_xp');
call prcdr_peer_with_highest_xp('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_longest_campus_visit_today');
call prcdr_longest_campus_visit_today('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_came_before');
call prcdr_came_before('ref', '15:00:00', 3);
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_left_during_time');
call prcdr_left_during_time('ref', 4, 300);
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_who_come_laster');
call prcdr_who_come_laster('ref');
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_who_come_back_in_time');
call prcdr_who_come_back_in_time('ref', 2);
fetch all in "ref";
commit;

begin;
call fnc_print('prcdr_early_in_birthday');
call prcdr_early_in_birthday('ref');
fetch all in "ref";
commit;
