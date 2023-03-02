-----------
-- Utils --
-----------
do $init_utils$ begin
    create or replace function get_csv_dir() returns varchar as $$ begin
        return '/Users/pmaryjo/Desktop/Info21_v1.0/cvs/';
    end $$ language plpgsql;

    create or replace procedure save_to_file(separator char, table_name varchar, file_name varchar) as $$ begin
        execute format('copy %s to ''%s'' delimiter ''%s'' csv', table_name, concat(get_csv_dir(), file_name), separator);
    end $$ language plpgsql;

    create or replace procedure read_from_file(separator char, table_name varchar, file_name varchar) as $$ begin
        execute format('copy %s from ''%s'' delimiter ''%s'' csv', table_name, concat(get_csv_dir(), file_name), separator);
    end $$ language plpgsql;

    create or replace procedure fill_tables() as $$ begin
        -- Peers
        insert into Peers values('Nickname_1', '2001-01-01');
        insert into Peers values('Nickname_2', '2002-02-02');
        insert into Peers values('Nickname_3', '2003-03-03');
        insert into Peers values('Nickname_4', '2004-04-04');
        insert into Peers values('Nickname_5', '2005-05-05');

        -- Tasks
        insert into Tasks values('CPP1', null, 300);
        insert into Tasks values('CPP2', 'CPP1', 400);
        insert into Tasks values('CPP3', 'CPP2', 300);
        insert into Tasks values('CPP4', 'CPP3', 350);
        insert into Tasks values('CPP5', 'CPP4', 400);

        -- Checks
        insert into Checks values(1, 'Nickname_1', 'CPP1', '2023-02-01');
        insert into Checks values(2, 'Nickname_2', 'CPP2', '2023-02-02');
        insert into Checks values(3, 'Nickname_3', 'CPP3', '2023-02-03');
        insert into Checks values(4, 'Nickname_4', 'CPP4', '2023-02-04');
        insert into Checks values(5, 'Nickname_5', 'CPP3', '2023-02-05');
        insert into Checks values(6, 'Nickname_5', 'CPP4', '2023-02-06');
        insert into Checks values(7, 'Nickname_5', 'CPP5', '2023-02-07');

        -- P2P
        insert into P2P values(1, 1, 'Nickname_2', 'Start', '12:13:14');
        insert into P2P values(2, 1, 'Nickname_2', 'Success', '13:14:15');

        insert into P2P values(3, 2, 'Nickname_3', 'Start', '15:16:17');
        insert into P2P values(4, 2, 'Nickname_3', 'Failure', '16:17:18');

        insert into P2P values(5, 3, 'Nickname_4', 'Start', '17:18:19');
        insert into P2P values(6, 3, 'Nickname_4', 'Success', '18:19:20');

        insert into P2P values(7, 4, 'Nickname_5', 'Start', '18:19:20');
        insert into P2P values(8, 4, 'Nickname_5', 'Success', '19:20:21');

        insert into P2P values(9, 5, 'Nickname_1', 'Start', '19:20:21');
        insert into P2P values(10, 5, 'Nickname_1', 'Success', '20:21:22');

        insert into P2P values(11, 6, 'Nickname_2', 'Start', '20:21:22');
        insert into P2P values(12, 6, 'Nickname_2', 'Success', '21:22:23');

        insert into P2P values(13, 7, 'Nickname_3', 'Start', '21:22:23');
        insert into P2P values(14, 7, 'Nickname_3', 'Success', '22:23:24');

        -- Verter
        insert into Verter values(1, 1, 'Start', '13:14:15');
        insert into Verter values(2, 1, 'Success', '13:15:15');

        insert into Verter values(5, 3, 'Start', '18:19:20');
        insert into Verter values(6, 3, 'Success', '18:20:20');

        insert into Verter values(7, 4, 'Start', '19:20:21');
        insert into Verter values(8, 4, 'Failure', '19:21:21');

        insert into Verter values(9, 5, 'Start', '20:21:22');
        insert into Verter values(10, 5, 'Success', '20:22:22');

        insert into Verter values(11, 6, 'Start', '21:22:23');
        insert into Verter values(12, 6, 'Success', '21:23:23');

        insert into Verter values(13, 7, 'Start', '22:23:24');
        insert into Verter values(14, 7, 'Success', '22:24:24');

        -- TransferredPoints
        insert into TransferredPoints values(1, 'Nickname_2', 'Nickname_1', 1);
        insert into TransferredPoints values(2, 'Nickname_3', 'Nickname_2', 1);
        insert into TransferredPoints values(3, 'Nickname_4', 'Nickname_3', 1);
        insert into TransferredPoints values(4, 'Nickname_5', 'Nickname_4', 1);
        insert into TransferredPoints values(5, 'Nickname_1', 'Nickname_5', 1);
        insert into TransferredPoints values(6, 'Nickname_2', 'Nickname_5', 1);
        insert into TransferredPoints values(7, 'Nickname_3', 'Nickname_5', 1);

        -- Friends
        insert into Friends values(1, 'Nickname_1', 'Nickname_2');
        insert into Friends values(2, 'Nickname_2', 'Nickname_3');
        insert into Friends values(3, 'Nickname_3', 'Nickname_4');
        insert into Friends values(4, 'Nickname_4', 'Nickname_5');
        insert into Friends values(5, 'Nickname_5', 'Nickname_1');

        -- Recommendations
        insert into Recommendations values(1, 'Nickname_1', 'Nickname_3');
        insert into Recommendations values(2, 'Nickname_2', 'Nickname_4');
        insert into Recommendations values(3, 'Nickname_3', 'Nickname_5');
        insert into Recommendations values(4, 'Nickname_4', 'Nickname_3');
        insert into Recommendations values(5, 'Nickname_5', 'Nickname_1');

        -- XP
        insert into XP values(1, 1, 300);
        insert into XP values(2, 3, 300);
        insert into XP values(3, 5, 300);
        insert into XP values(4, 6, 350);
        insert into XP values(5, 7, 400);

        -- TimeTracking
        insert into TimeTracking values(1, 'Nickname_1', '2023-02-01', '11:24:11', 1);
        insert into TimeTracking values(2, 'Nickname_1', '2023-02-01', '23:42:00', 2);

        insert into TimeTracking values(3, 'Nickname_3', '2023-02-03', '09:05:54', 1);
        insert into TimeTracking values(4, 'Nickname_3', '2023-02-03', '23:42:00', 2);

        insert into TimeTracking values(5, 'Nickname_2', '2023-02-10', '13:44:01', 1);
        insert into TimeTracking values(6, 'Nickname_2', '2023-02-10', '23:42:00', 2);
    end $$ language plpgsql;
end $init_utils$;


-------------------
-- ENUM creation --
-------------------
do $create_enum$ begin
    create type check_status as enum(
        'Start',
        'Success',
        'Failure'
    );
exception
    when duplicate_object then null;
end $create_enum$;


------------
-- Tables --
------------
do $create_tables$ begin
    create table if not exists Peers(
        Nickname varchar primary key,
        Bitrhday date
    );

    create table if not exists Tasks(
        Title varchar primary key,
        ParentTask varchar,
        MaxXP int,
        constraint fk_tasks_parent_task foreign key (ParentTask) references Tasks(Title)
    );

    create table if not exists Checks(
        ID bigint primary key,
        Peer varchar,
        Task varchar,
        Date date,
        constraint fk_checks_peer foreign key (Peer) references Peers(Nickname)
    );

    create table if not exists P2P(
        ID bigint primary key,
        "Check" bigint,
        CheckingPeer varchar,
        State check_status,
        Time time,
        constraint fk_p2p_chech foreign key ("Check") references Checks(ID),
        constraint fk_p2p_checking_peer foreign key (CheckingPeer) references Peers(Nickname)
    );

    create table if not exists Verter(
        ID bigint primary key,
        "Check" bigint,
        State check_status,
        Time time,
        constraint fk_verter_check foreign key ("Check") references Checks(ID)
    );

    create table if not exists TransferredPoints(
        ID bigint primary key,
        CheckingPeer varchar,
        CheckedPeer varchar,
        PointsAmount int,
        constraint fk_transferred_points_checking_peer foreign key (CheckingPeer) references Peers(Nickname),
        constraint fk_transferred_points_checked_peer foreign key (CheckedPeer) references Peers(Nickname)
    );

    create table if not exists Friends(
        ID bigint primary key,
        Peer1 varchar,
        Peer2 varchar,
        constraint fk_friends_peer1 foreign key (Peer1) references Peers(Nickname),
        constraint fk_friends_peer2 foreign key (Peer2) references Peers(Nickname)
    );

    create table if not exists Recommendations(
        ID bigint primary key,
        Peer varchar,
        RecommendedPeer varchar,
        constraint fk_recommendations_peer foreign key (Peer) references Peers(Nickname),
        constraint fk_recommendations_recommended_peer foreign key (RecommendedPeer) references Peers(Nickname)
    );

    create table if not exists XP(
        ID bigint primary key,
        "Check" bigint,
        XPAmount int,
        constraint fk_xp_check foreign key ("Check") references Checks(ID)
    );

    create table if not exists TimeTracking(
        ID bigint primary key,
        Peer varchar,
        Date date,
        Time time,
        State int,
        constraint fk_time_tracking_peer foreign key (Peer) references Peers(Nickname),
        constraint ch_state check (State in (1, 2))
    );
end $create_tables$;


------------------------------
-- To/From files procedures --
------------------------------
do $init_procedures$ begin
    -- Peers
    create or replace procedure peers_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'Peers', 'peers.cvs');
    end; $$ language plpgsql;

    create or replace procedure peers_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'Peers', 'peers.cvs');
    end; $$ language plpgsql;

    -- Tasks
    create or replace procedure tasks_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'Tasks', 'tasks.cvs');
    end; $$ language plpgsql;

    create or replace procedure tasks_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'Tasks', 'tasks.cvs');
    end; $$ language plpgsql;

    -- Checks
    create or replace procedure checks_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'Checks', 'checks.cvs');
    end; $$ language plpgsql;

    create or replace procedure checks_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'Checks', 'checks.cvs');
    end; $$ language plpgsql;

    -- P2P
    create or replace procedure p2p_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'P2P', 'p2p.cvs');
    end; $$ language plpgsql;

    create or replace procedure p2p_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'P2P', 'p2p.cvs');
    end; $$ language plpgsql;

    -- Verter
    create or replace procedure verter_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'Verter', 'verter.cvs');
    end; $$ language plpgsql;

    create or replace procedure verter_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'Verter', 'verter.cvs');
    end; $$ language plpgsql;

    -- TransferredPoints
    create or replace procedure transferred_points_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'TransferredPoints', 'transferred_points.cvs');
    end; $$ language plpgsql;

    create or replace procedure transferred_points_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'TransferredPoints', 'transferred_points.cvs');
    end; $$ language plpgsql;

    -- Friends
    create or replace procedure friends_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'Friends', 'friends.cvs');
    end; $$ language plpgsql;

    create or replace procedure friends_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'Friends', 'friends.cvs');
    end; $$ language plpgsql;

    -- Recommendations
    create or replace procedure recommendations_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'Recommendations', 'recommendations.cvs');
    end; $$ language plpgsql;

    create or replace procedure recommendations_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'Recommendations', 'recommendations.cvs');
    end; $$ language plpgsql;

    -- XP
    create or replace procedure xp_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'XP', 'xp.cvs');
    end; $$ language plpgsql;

    create or replace procedure xp_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'XP', 'xp.cvs');
    end; $$ language plpgsql;

    -- TimeTracking
    create or replace procedure timetracking_tofile(sep char default ',') as $$ begin
        call save_to_file(sep, 'TimeTracking', 'time_tracking.cvs');
    end; $$ language plpgsql;

    create or replace procedure timetracking_fromfile(sep char default ',') as $$ begin
        call read_from_file(sep, 'TimeTracking', 'time_tracking.cvs');
    end; $$ language plpgsql;
end $init_procedures$;


-----------------------
-- Trigger functions --
-----------------------
do $trigger_functions$ begin
    create or replace function trg_fnc_successful_checks() returns trigger as $$ begin
        if (coalesce((
                select "Check"
                from P2P
                where P2P."Check" = new."Check" and P2P.State = 'Success'
                intersect
                select ID
                from Checks
                where Checks.ID = new."Check"
            )::int, 0) != 0
        ) then
            return new;
        else return null;
        end if;
    end; $$ language plpgsql;

    create or replace function trg_fnc_p2p_insert() returns trigger as $$
    declare
        cnt int := count(*) from
                    (
                        select
                            *
                        from P2P
                        left join Checks
                            on P2P."Check" = Checks.ID
                        where new."Check" = Checks.ID and
                            new.CheckingPeer = P2P.CheckingPeer
                    ) as tmp;
    begin
        if (cnt % 2 != 0 and new.State = 'Start' or
                cnt % 2 = 0 and new.State != 'Start') then
            return null;
        else
            return new;
        end if;
    end; $$ language plpgsql;

    create or replace function trg_fnc_transferred_points_insert() returns trigger as $$
    declare
        n int;
    begin

        update TransferredPoints set PointsAmount = PointsAmount + 1
        where TransferredPoints.CheckingPeer = new.CheckingPeer and
            TransferredPoints.CheckedPeer = new.CheckedPeer;
        get diagnostics n = row_count;

        if (n != 0) then
            return null;
        else
            return new;
        end if;
    end; $$ language plpgsql;

    -- Verter
    create trigger trg_verter_successful_checks
    before insert on Verter
    for each row
    execute procedure trg_fnc_successful_checks();

    -- XP
    create trigger trg_xp_successful_checks
    before insert on XP
    for each row
    execute procedure trg_fnc_successful_checks();

    -- P2P
    create trigger trg_p2p_insert
    before insert on P2P
    for each row
    execute procedure trg_fnc_p2p_insert();

    -- TransferredPoints
    create trigger trg_transferred_points_insert
    before insert on TransferredPoints
    for each row
    execute procedure trg_fnc_transferred_points_insert();
end $trigger_functions$ language plpgsql;


-----------------
-- Fill tables --
-----------------
-- call fill_tables();
