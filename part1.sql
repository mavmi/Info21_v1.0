----------
-- ENUM --
----------
do
$create_enum$
begin
    create type check_status as enum(
        'Start',
        'Success',
        'Failure'
    );
exception
    when duplicate_object then null;
end
$create_enum$;


------------
-- Tables --
------------
create or replace procedure peers(fill boolean) as
$$
begin
    create table if not exists Peers(
        Nickname varchar primary key,
        Birthday date
    );

    if (fill = false) then
        return;
    end if;

    insert into Peers values('Wolf', '1990-02-04');
    insert into Peers values('Sprat_eater', '1999-02-05');
    insert into Peers values('Near_Muslim', '1980-12-10');
    insert into Peers values('Pirate', '1994-02-27');
    insert into Peers values('Strangler', '2000-12-24');
    insert into Peers values('Gabriel', '1998-02-12');
    insert into Peers values('Luisi', '1977-03-07');
end;
$$ language plpgsql;

create or replace procedure tasks(fill boolean) as
$$
begin
    create table if not exists Tasks(
        Title varchar primary key,
        ParentTask varchar,
        MaxXP int,
        constraint fk_tasks_parent_task foreign key (ParentTask) references Tasks(Title)
    );

    if (fill = false) then
        return;
    end if;

    insert into Tasks values('DO1', null, 300);
    insert into Tasks values('DO2', 'DO1', 250);
    insert into Tasks values('DO3', 'DO2', 350);
    insert into Tasks values('DO4', 'DO3', 350);
    insert into Tasks values('DO5', 'DO4', 300);
    insert into Tasks values('DO6', 'DO5', 300);

    insert into Tasks values('CPP1', null, 300);
    insert into Tasks values('CPP2', 'CPP1', 400);
    insert into Tasks values('CPP3', 'CPP2', 300);
    insert into Tasks values('CPP4', 'CPP3', 350);
    insert into Tasks values('CPP5', 'CPP4', 400);

    insert into Tasks values('A1', null, 300);
    insert into Tasks values('A2', 'A1', 400);
    insert into Tasks values('A3', 'A2', 300);
    insert into Tasks values('A4', 'A3', 350);
    insert into Tasks values('A5', 'A4', 400);
    insert into Tasks values('A6', 'A5', 700);
    insert into Tasks values('A7', 'A6', 800);
    insert into Tasks values('A8', 'A7', 800);

    insert into Tasks values('SQL1', null, 1500);
    insert into Tasks values('SQL2', 'SQL1', 500);
    insert into Tasks values('SQL3', 'SQL2', 600);
end;
$$ language plpgsql;

create or replace procedure checks(fill boolean) as
$$
begin
    create table if not exists Checks(
        ID bigint primary key,
        Peer varchar,
        Task varchar,
        Date date,
        constraint fk_checks_peer foreign key (Peer) references Peers(Nickname)
    );

    if (fill = false) then
        return;
    end if;

    /*
     * Tasks pull:
     * 1. 'Wolf'        -> CPP1-CPP4, CPP5(2)
     * 2. 'Sprat_eater' -> DO1(2), DO2(2), CPP1, CPP2(2), CPP3
     * 3. 'Near_Muslim' -> DO1-DO6, CPP1, SQL1
     * 4. 'Pirate'      -> CPP1-CPP5
     * 5. 'Strangler'   -> A1-A8, SQL1
     * 6. 'Gabriel'     -> A1-A7, A8(2), SQL1-SQL2
     * 7. 'Luisi'       -> SQL1-SQL2, SQL3(3)
     */

     /*
      * Successfull passeds on birthday [id, module, state]:
      * 1. 'Wolf'        -> [27, CPP1, Success]
      * 2. 'Sprat_eater' -> [28, CPP2, Failure]
      * 3. 'Near_Muslim' -> [5, DO1, Success]
      * 4. 'Pirate'      -> [didnt passed to birthday]
      * 5. 'Strangler'   -> [12, A4, Success]
      * 6. 'Gabriel'     -> [37, A8, Failure]
      * 7. 'Luisi'       -> [50, SQL3, Success]
      */

    insert into Checks values(1, 'Near_Muslim', 'DO1', '2022-12-01');
    insert into Checks values(2, 'Strangler', 'A1', '2022-12-01');
    insert into Checks values(3, 'Gabriel', 'A1', '2022-12-01');

    insert into Checks values(4, 'Gabriel', 'A2', '2022-12-03');

    insert into Checks values(5, 'Near_Muslim', 'DO2', '2022-12-10');
    insert into Checks values(6, 'Strangler', 'A2', '2022-12-10');
    insert into Checks values(7, 'Gabriel', 'A3', '2022-12-10');

    insert into Checks values(8, 'Near_Muslim', 'DO3', '2022-12-15');
    insert into Checks values(9, 'Strangler', 'A3', '2022-12-15');
    insert into Checks values(10, 'Gabriel', 'A4', '2022-12-15');

    insert into Checks values(11, 'Near_Muslim', 'DO4', '2022-12-24');
    insert into Checks values(12, 'Strangler', 'A4', '2022-12-24');
    insert into Checks values(13, 'Gabriel', 'A5', '2022-12-24');

    insert into Checks values(14, 'Near_Muslim', 'DO5', '2023-01-03');
    insert into Checks values(15, 'Sprat_eater', 'DO1', '2023-01-03');
    insert into Checks values(16, 'Strangler', 'A5', '2023-01-03');

    insert into Checks values(17, 'Sprat_eater', 'DO1', '2023-01-05');

    insert into Checks values(18, 'Sprat_eater', 'DO2', '2023-01-15');
    insert into Checks values(19, 'Near_Muslim', 'DO6', '2023-01-15');
    insert into Checks values(20, 'Strangler', 'A6', '2023-01-15');
    insert into Checks values(21, 'Gabriel', 'A6', '2023-01-15');

    insert into Checks values(22, 'Near_Muslim', 'CPP1', '2023-02-01');
    insert into Checks values(23, 'Sprat_eater', 'CPP1', '2023-02-01');
    insert into Checks values(24, 'Strangler', 'A7', '2023-02-01');
    insert into Checks values(25, 'Gabriel', 'A7', '2023-02-01');

    insert into Checks values(26, 'Pirate', 'CPP1', '2023-02-04');
    insert into Checks values(27, 'Wolf', 'CPP1', '2023-02-04');

    insert into Checks values(28, 'Sprat_eater', 'CPP2', '2023-02-05');
    insert into Checks values(29, 'Pirate', 'CPP2', '2023-02-05');
    insert into Checks values(30, 'Wolf', 'CPP2', '2023-02-05');

    insert into Checks values(31, 'Sprat_eater', 'CPP2', '2023-02-09');
    insert into Checks values(32, 'Pirate', 'CPP3', '2023-02-09');
    insert into Checks values(33, 'Wolf', 'CPP3', '2023-02-09');

    insert into Checks values(34, 'Sprat_eater', 'CPP3', '2023-02-12');
    insert into Checks values(35, 'Strangler', 'A8', '2023-02-12');
    insert into Checks values(36, 'Pirate', 'CPP4', '2023-02-12');
    insert into Checks values(37, 'Gabriel', 'A8', '2023-02-12');
    insert into Checks values(38, 'Wolf', 'CPP4', '2023-02-12');

    insert into Checks values(39, 'Wolf', 'CPP5', '2023-02-25');

    insert into Checks values(40, 'Strangler', 'SQL1', '2023-02-27');
    insert into Checks values(41, 'Gabriel', 'A8', '2023-02-27');
    insert into Checks values(42, 'Pirate', 'CPP5', '2023-02-27');
    insert into Checks values(43, 'Luisi', 'SQL1', '2023-02-27');
    insert into Checks values(44, 'Gabriel', 'SQL1', '2023-02-27');
    insert into Checks values(45, 'Wolf', 'CPP5', '2023-02-27');

    insert into Checks values(46, 'Gabriel', 'SQL2', '2023-03-01');
    insert into Checks values(47, 'Luisi', 'SQL2', '2023-03-01');

    insert into Checks values(48, 'Luisi', 'SQL3', '2023-03-05');

    insert into Checks values(49, 'Luisi', 'SQL3', '2023-03-06');

    insert into Checks values(50, 'Luisi', 'SQL3', '2023-03-07');
    insert into Checks values(51, 'Sprat_eater', 'DO2', '2023-03-07'); --Repassing
    insert into Checks values(52, 'Near_Muslim', 'SQL1', '2023-03-07');
    insert into Checks values(53, 'Wolf', 'CPP5', '2023-03-07'); --Repassing

    insert into Checks values(54, 'Sprat_eater', 'DO1', '2023-03-08'); --Repassing
end;
$$ language plpgsql;

create or replace procedure p2p(fill boolean) as
$$
begin
    create table if not exists P2P(
        ID bigint primary key,
        "Check" bigint,
        CheckingPeer varchar,
        State check_status,
        Time time,
        constraint fk_p2p_chech foreign key ("Check") references Checks(ID),
        constraint fk_p2p_checking_peer foreign key (CheckingPeer) references Peers(Nickname)
    );

    if (fill = false) then
        return;
    end if;

    insert into P2P values(fnc_next_id('P2P'), 1, 'Luisi', 'Start', '16:00:57');
    insert into P2P values(fnc_next_id('P2P'), 1, 'Luisi', 'Success', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 2, 'Luisi', 'Start', '16:18:57');
    insert into P2P values(fnc_next_id('P2P'), 2, 'Luisi', 'Success', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 3, 'Near_Muslim', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 3, 'Near_Muslim', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 4, 'Pirate', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 4, 'Pirate', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 5, 'Gabriel', 'Start', '15:16:17');
    insert into P2P values(fnc_next_id('P2P'), 5, 'Gabriel', 'Success', '16:17:18');

    insert into P2P values(fnc_next_id('P2P'), 6, 'Near_Muslim', 'Start', '18:15:20');
    insert into P2P values(fnc_next_id('P2P'), 6, 'Near_Muslim', 'Success', '19:15:21');

    insert into P2P values(fnc_next_id('P2P'), 7, 'Luisi', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 7, 'Luisi', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 8, 'Strangler', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 8, 'Strangler', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 9, 'Gabriel', 'Start', '10:19:20');
    insert into P2P values(fnc_next_id('P2P'), 9, 'Gabriel', 'Success', '11:20:21');

    insert into P2P values(fnc_next_id('P2P'), 10, 'Pirate', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 10, 'Pirate', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 11, 'Pirate', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 11, 'Pirate', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 12, 'Wolf', 'Start', '18:19:20');
    insert into P2P values(fnc_next_id('P2P'), 12, 'Wolf', 'Success', '19:20:21');

    insert into P2P values(fnc_next_id('P2P'), 13, 'Wolf', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 13, 'Wolf', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 14, 'Luisi', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 14, 'Luisi', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 15, 'Luisi', 'Start', '12:13:14');
    insert into P2P values(fnc_next_id('P2P'), 15, 'Luisi', 'Failure', '13:14:15');

    insert into P2P values(fnc_next_id('P2P'), 16, 'Wolf', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 16, 'Wolf', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 17, 'Strangler', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 17, 'Strangler', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 18, 'Strangler', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 18, 'Strangler', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 19, 'Sprat_eater', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 19, 'Sprat_eater', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 20, 'Sprat_eater', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 20, 'Sprat_eater', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 21, 'Pirate', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 21, 'Pirate', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 22, 'Luisi', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 22, 'Luisi', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 23, 'Strangler', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 23, 'Strangler', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 24, 'Gabriel', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 24, 'Gabriel', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 25, 'Wolf', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 25, 'Wolf', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 26, 'Luisi', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 26, 'Luisi', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 27, 'Luisi', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 27, 'Luisi', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 28, 'Wolf', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 28, 'Wolf', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 29, 'Near_Muslim', 'Start', '17:18:19');
    insert into P2P values(fnc_next_id('P2P'), 29, 'Near_Muslim', 'Success', '18:19:20');

    insert into P2P values(fnc_next_id('P2P'), 30, 'Pirate', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 30, 'Pirate', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 31, 'Near_Muslim', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 31, 'Near_Muslim', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 32, 'Wolf', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 32, 'Wolf', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 33, 'Strangler', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 33, 'Strangler', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 34, 'Strangler', 'Start', '16:00:57');

    insert into P2P values(fnc_next_id('P2P'), 35, 'Gabriel', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 35, 'Gabriel', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 36, 'Near_Muslim', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 36, 'Near_Muslim', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 37, 'Near_Muslim', 'Start', '16:00:57');
    insert into P2P values(fnc_next_id('P2P'), 37, 'Near_Muslim', 'Failure', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 38, 'Luisi', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 38, 'Luisi', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 39, 'Pirate', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 39, 'Pirate', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 40, 'Wolf', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 40, 'Wolf', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 41, 'Wolf', 'Start', '20:21:22');
    insert into P2P values(fnc_next_id('P2P'), 41, 'Wolf', 'Success', '21:22:23');

    insert into P2P values(fnc_next_id('P2P'), 42, 'Gabriel', 'Start', '15:00:40');

    insert into P2P values(fnc_next_id('P2P'), 43, 'Wolf', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 43, 'Wolf', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 44, 'Pirate', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 44, 'Pirate', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 45, 'Pirate', 'Start', '16:00:57');
    insert into P2P values(fnc_next_id('P2P'), 45, 'Pirate', 'Success', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 46, 'Near_Muslim', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 46, 'Near_Muslim', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 47, 'Near_Muslim', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 47, 'Near_Muslim', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 48, 'Near_Muslim', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 48, 'Near_Muslim', 'Failure', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 49, 'Strangler', 'Start', '21:22:23');
    insert into P2P values(fnc_next_id('P2P'), 49, 'Strangler', 'Failure', '22:23:24');

    insert into P2P values(fnc_next_id('P2P'), 50, 'Gabriel', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 50, 'Gabriel', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 51, 'Pirate', 'Start', '21:16:07');
    insert into P2P values(fnc_next_id('P2P'), 51, 'Pirate', 'Success', '21:40:55');

    insert into P2P values(fnc_next_id('P2P'), 52, 'Pirate', 'Start', '23:00:05');
    insert into P2P values(fnc_next_id('P2P'), 52, 'Pirate', 'Success', '23:30:55');

    insert into P2P values(fnc_next_id('P2P'), 53, 'Luisi', 'Start', '22:00:05');
    insert into P2P values(fnc_next_id('P2P'), 53, 'Luisi', 'Success', '22:30:55');

    insert into P2P values(fnc_next_id('P2P'), 54, 'Strangler', 'Start', '20:00:05');
    insert into P2P values(fnc_next_id('P2P'), 54, 'Strangler', 'Success', '21:30:55');
end;
$$ language plpgsql;

create or replace procedure verter(fill boolean) as
$$
begin
    create table if not exists Verter(
        ID bigint primary key,
        "Check" bigint,
        State check_status,
        Time time,
        constraint fk_verter_check foreign key ("Check") references Checks(ID)
    );

    if (fill = false) then
        return;
    end if;

    insert into Verter values(fnc_next_id('Verter'), 1, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 1, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 2, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 2, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 3, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 3, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 4, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 4, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 5, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 5, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 6, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 6, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 7, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 7, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 8, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 8, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 9, 'Start', '21:22:23');
    insert into Verter values(fnc_next_id('Verter'), 9, 'Success', '21:23:23');

    insert into Verter values(fnc_next_id('Verter'), 10, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 10, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 11, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 11, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 12, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 12, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 13, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 13, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 14, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 14, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 16, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 16, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 17, 'Start', '21:22:23');
    insert into Verter values(fnc_next_id('Verter'), 17, 'Success', '21:23:23');

    insert into Verter values(fnc_next_id('Verter'), 18, 'Start', '21:22:23');
    insert into Verter values(fnc_next_id('Verter'), 18, 'Success', '21:23:23');

    insert into Verter values(fnc_next_id('Verter'), 19, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 19, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 20, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 20, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 21, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 21, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 22, 'Start', '21:22:23');
    insert into Verter values(fnc_next_id('Verter'), 22, 'Success', '21:23:23');

    insert into Verter values(fnc_next_id('Verter'), 23, 'Start', '19:20:21');
    insert into Verter values(fnc_next_id('Verter'), 23, 'Success', '19:21:21');

    insert into Verter values(fnc_next_id('Verter'), 24, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 24, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 25, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 25, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 26, 'Start', '19:20:21');
    insert into Verter values(fnc_next_id('Verter'), 26, 'Success', '19:21:21');

    insert into Verter values(fnc_next_id('Verter'), 27, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 27, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 28, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 28, 'Failure', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 29, 'Start', '19:20:21');
    insert into Verter values(fnc_next_id('Verter'), 29, 'Success', '19:21:21');

    insert into Verter values(fnc_next_id('Verter'), 30, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 30, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 31, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 31, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 32, 'Start', '20:21:22');
    insert into Verter values(fnc_next_id('Verter'), 32, 'Success', '20:22:22');

    insert into Verter values(fnc_next_id('Verter'), 33, 'Start', '19:20:21');
    insert into Verter values(fnc_next_id('Verter'), 33, 'Success', '19:21:21');

    insert into Verter values(fnc_next_id('Verter'), 35, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 35, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 36, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 36, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 38, 'Start', '21:22:23');
    insert into Verter values(fnc_next_id('Verter'), 38, 'Success', '21:23:23');

    insert into Verter values(fnc_next_id('Verter'), 39, 'Start', '21:22:23');
    insert into Verter values(fnc_next_id('Verter'), 39, 'Failure', '21:23:23');

    insert into Verter values(fnc_next_id('Verter'), 41, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 41, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 45, 'Start', '13:14:15');
    insert into Verter values(fnc_next_id('Verter'), 45, 'Success', '13:15:15');

    insert into Verter values(fnc_next_id('Verter'), 51, 'Start', '21:41:00');
    insert into Verter values(fnc_next_id('Verter'), 51, 'Success', '21:41:30');

    insert into Verter values(fnc_next_id('Verter'), 53, 'Start', '21:41:00');
    insert into Verter values(fnc_next_id('Verter'), 53, 'Success', '21:41:30');

    insert into Verter values(fnc_next_id('Verter'), 54, 'Start', '21:41:00');
    insert into Verter values(fnc_next_id('Verter'), 54, 'Success', '21:41:30');
end;
$$ language plpgsql;

create or replace procedure transferred_points(fill boolean) as
$$
begin
    create table if not exists TransferredPoints(
        ID bigint primary key,
        CheckingPeer varchar,
        CheckedPeer varchar,
        PointsAmount int,
        constraint fk_transferred_points_checking_peer foreign key (CheckingPeer) references Peers(Nickname),
        constraint fk_transferred_points_checked_peer foreign key (CheckedPeer) references Peers(Nickname)
    );

    if (fill = false) then
        return;
    end if;

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Gabriel', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Gabriel', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Sprat_eater', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Sprat_eater', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Gabriel', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Pirate', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Wolf', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Pirate', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Wolf', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Pirate', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Wolf', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Gabriel', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Pirate', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Wolf', 'Luisi', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Wolf', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Pirate', 'Gabriel', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Luisi', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Wolf', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Gabriel', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Luisi', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Luisi', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Luisi', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Luisi', 'Gabriel', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Sprat_eater', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Near_Muslim', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Luisi', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'),'Strangler', 'Sprat_eater', 1);
end
$$ language plpgsql;

create or replace procedure friends(fill boolean) as
$$
begin
    create table if not exists Friends(
        ID bigint primary key,
        Peer1 varchar,
        Peer2 varchar,
        constraint fk_friends_peer1 foreign key (Peer1) references Peers(Nickname),
        constraint fk_friends_peer2 foreign key (Peer2) references Peers(Nickname)
    );

    if (fill = false) then
        return;
    end if;

    /*
        Friends:

        'Wolf' -> ['Gabriel'/'Luisi'/'Pirate'/'Sprat_eater'/'Strangler'],
        'Sprat_eater' -> ['Luisi'/'Near_Muslim'/'Wolf']
        'Near_Muslim' -> ['Gabriel'/'Luisi'/'Pirate'/'Sprat_eater']
        'Pirate' -> ['Near_Muslim'/'Strangler'/'Wolf'],
        'Strangler' -> ['Pirate'/'Wolf'],
        'Gabriel' -> ['Luisi'/'Near_Muslim'/'Wolf'],
        'Luisi' -> ['Gabriel'/'Near_Muslim'/'Sprat_eater'/'Wolf']
    */

    insert into Friends values(fnc_next_id('Friends'), 'Wolf', 'Sprat_eater');
    insert into Friends values(fnc_next_id('Friends'), 'Wolf', 'Luisi');
    insert into Friends values(fnc_next_id('Friends'), 'Wolf', 'Gabriel');
    insert into Friends values(fnc_next_id('Friends'), 'Sprat_eater', 'Near_Muslim');
    insert into Friends values(fnc_next_id('Friends'), 'Sprat_eater', 'Luisi');
    insert into Friends values(fnc_next_id('Friends'), 'Near_Muslim', 'Gabriel');
    insert into Friends values(fnc_next_id('Friends'), 'Near_Muslim', 'Pirate');
    insert into Friends values(fnc_next_id('Friends'), 'Pirate', 'Wolf');
    insert into Friends values(fnc_next_id('Friends'), 'Pirate', 'Strangler');
    insert into Friends values(fnc_next_id('Friends'), 'Strangler', 'Wolf');
    insert into Friends values(fnc_next_id('Friends'), 'Luisi', 'Near_Muslim');
    insert into Friends values(fnc_next_id('Friends'), 'Gabriel', 'Luisi');
end;
$$ language plpgsql;

create or replace procedure recommendations(fill boolean) as
$$
begin
    create table if not exists Recommendations(
        ID bigint primary key,
        Peer varchar,
        RecommendedPeer varchar,
        constraint fk_recommendations_peer foreign key (Peer) references Peers(Nickname),
        constraint fk_recommendations_recommended_peer foreign key (RecommendedPeer) references Peers(Nickname)
    );

    if (fill = false) then
        return;
    end if;

    insert into Recommendations values(fnc_next_id('Recommendations'), 'Wolf', 'Near_Muslim');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Wolf', 'Pirate');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Wolf', 'Strangler');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Sprat_eater', 'Pirate');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Near_Muslim', 'Luisi');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Near_Muslim', 'Gabriel');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Pirate', 'Sprat_eater');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Pirate', 'Gabriel');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Strangler', 'Gabriel');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Strangler', 'Wolf');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Strangler', 'Pirate');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Strangler', 'Luisi');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Gabriel', 'Sprat_eater');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Luisi', 'Sprat_eater');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Luisi', 'Pirate');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Luisi', 'Gabriel');
end;
$$ language plpgsql;

create or replace procedure xp(fill boolean) as
$$
begin
    create table if not exists XP(
        ID bigint primary key,
        "Check" bigint,
        XPAmount int,
        constraint fk_xp_check foreign key ("Check") references Checks(ID)
    );

    if (fill = false) then
        return;
    end if;

    insert into XP values(fnc_next_id('XP'), 1, 300);
    insert into XP values(fnc_next_id('XP'), 2, 300);
    insert into XP values(fnc_next_id('XP'), 3, 300);
    insert into XP values(fnc_next_id('XP'), 4, 400);
    insert into XP values(fnc_next_id('XP'), 5, 240);
    insert into XP values(fnc_next_id('XP'), 6, 400);
    insert into XP values(fnc_next_id('XP'), 7, 300);
    insert into XP values(fnc_next_id('XP'), 8, 350);
    insert into XP values(fnc_next_id('XP'), 9, 300);
    insert into XP values(fnc_next_id('XP'), 10, 350);
    insert into XP values(fnc_next_id('XP'), 11, 350);
    insert into XP values(fnc_next_id('XP'), 12, 350);
    insert into XP values(fnc_next_id('XP'), 13, 400);
    insert into XP values(fnc_next_id('XP'), 14, 300);
    insert into XP values(fnc_next_id('XP'), 16, 400);
    insert into XP values(fnc_next_id('XP'), 17, 290);
    insert into XP values(fnc_next_id('XP'), 18, 240);
    insert into XP values(fnc_next_id('XP'), 19, 300);
    insert into XP values(fnc_next_id('XP'), 20, 700);
    insert into XP values(fnc_next_id('XP'), 21, 700);
    insert into XP values(fnc_next_id('XP'), 22, 300);
    insert into XP values(fnc_next_id('XP'), 23, 300);
    insert into XP values(fnc_next_id('XP'), 24, 800);
    insert into XP values(fnc_next_id('XP'), 25, 800);
    insert into XP values(fnc_next_id('XP'), 26, 300);
    insert into XP values(fnc_next_id('XP'), 27, 300);
    insert into XP values(fnc_next_id('XP'), 29, 400);
    insert into XP values(fnc_next_id('XP'), 30, 400);
    insert into XP values(fnc_next_id('XP'), 31, 300);
    insert into XP values(fnc_next_id('XP'), 32, 300);
    insert into XP values(fnc_next_id('XP'), 33, 300);
    insert into XP values(fnc_next_id('XP'), 35, 800);
    insert into XP values(fnc_next_id('XP'), 36, 340);
    insert into XP values(fnc_next_id('XP'), 38, 350);
    insert into XP values(fnc_next_id('XP'), 40, 1500);
    insert into XP values(fnc_next_id('XP'), 41, 800);
    insert into XP values(fnc_next_id('XP'), 43, 1400);
    insert into XP values(fnc_next_id('XP'), 44, 1500);
    insert into XP values(fnc_next_id('XP'), 45, 390);
    insert into XP values(fnc_next_id('XP'), 46, 500);
    insert into XP values(fnc_next_id('XP'), 47, 500);
    insert into XP values(fnc_next_id('XP'), 50, 580);
    insert into XP values(fnc_next_id('XP'), 51, 250);
    insert into XP values(fnc_next_id('XP'), 52, 1450);
    insert into XP values(fnc_next_id('XP'), 53, 400);
    insert into XP values(fnc_next_id('XP'), 54, 300);
end;
$$ language plpgsql;

create or replace procedure time_tracking(fill boolean) as
$$
begin
    create table if not exists TimeTracking(
        ID bigint primary key,
        Peer varchar,
        Date date,
        Time time,
        State int,
        constraint fk_time_tracking_peer foreign key (Peer) references Peers(Nickname),
        constraint ch_state check (State in (1, 2))
    );

    if (fill = false) then
        return;
    end if;

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2022-12-01', '11:24:11', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2022-12-01', '23:42:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2022-12-01', '09:05:54', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2022-12-01', '23:42:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Sprat_eater', '2022-12-05', '13:44:01', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Sprat_eater', '2022-12-05', '23:42:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Pirate', '2022-12-07', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Pirate', '2022-12-07', '23:59:59', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2022-12-10', '23:59:59', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2022-12-11', '02:42:59', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2022-12-11', '05:41:34', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2022-12-11', '20:30:47', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Gabriel', '2022-12-28', '20:30:47', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Gabriel', '2022-12-29', '00:49:44', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Gabriel', '2022-12-30', '13:49:44', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Gabriel', '2022-12-31', '05:17:02', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Pirate', '2022-12-30', '19:07:45', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Pirate', '2022-12-31', '03:17:55', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2023-01-01', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2023-01-01', '23:59:59', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Luisi', '2023-01-10', '08:50:52', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Luisi', '2023-01-10', '17:04:02', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2023-01-20', '15:59:59', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2023-01-20', '23:59:52', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2023-01-30', '09:41:34', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2023-01-30', '20:00:47', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Gabriel', '2023-02-04', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Gabriel', '2023-02-05', '00:50:44', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Sprat_eater', '2023-02-16', '13:49:44', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Sprat_eater', '2023-02-17', '05:17:02', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Luisi', '2023-02-25', '19:07:45', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Luisi', '2023-02-25', '22:14:04', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2023-03-07', '00:00:00', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Strangler', '2023-03-08', '09:04:16', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Luisi', '2023-03-08', '08:50:52', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Luisi', '2023-03-08', '17:04:02', 2);
end;
$$ language plpgsql;

do
$create_tables$
declare
    /*** Do or not do inserts ***/
    fill boolean := true;
begin
    /*** Tables creating and possibly filling ***/
    call peers(fill);
    call tasks(fill);
    call checks(fill);
    call p2p(fill);
    call verter(fill);
    call transferred_points(fill);
    call friends(fill);
    call recommendations(fill);
    call xp(fill);
    call time_tracking(fill);
end;
$create_tables$;


/*** Utils ***/
create or replace function get_cvs_dir() returns varchar as
$$
begin
    return '/Users/msalena/Desktop/00SQL/cvs/';
end
$$ language plpgsql;
create or replace procedure save_to_file(separator char, table_name varchar, file_name varchar) as
$$
begin
    execute format('copy %s to ''%s'' delimiter ''%s'' csv', table_name, concat(get_cvs_dir(), file_name), separator);
end
$$ language plpgsql;
create or replace procedure read_from_file(separator char, table_name varchar, file_name varchar) as
$$
begin
    execute format('copy %s from ''%s'' delimiter ''%s'' csv', table_name, concat(get_cvs_dir(), file_name), separator);
end
$$ language plpgsql;


/*** Trigger functions ***/
-- Check if current insertion has successful P2P --
create or replace function trg_fnc_successful_checks() returns trigger as
$$
begin
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
    else
        return null;
    end if;
end;
$$ language plpgsql;

-- Check `CheckingPeer` on start and finish --
create or replace function trg_fnc_p2p_insert_1() returns trigger as
$$
declare

begin
    if (new.State = 'Start') then
        return new;
    elsif   ((
                select
                    CheckingPeer
                from P2P
                where P2P."Check" = new."Check" and
                    P2P.State = 'Start'
                limit 1
            ) != new.CheckingPeer) then
        return null;
    else
        return new;
    end if;

end;
$$ language plpgsql;

-- Check if new row does not duplicate P2P-check with started or finished status --
create or replace function trg_fnc_p2p_insert_2() returns trigger as
$$
declare
    values int array[2] :=  (
                                select
                                    array[
                                        count(*) filter (where new."Check" = Checks.ID and new.CheckingPeer = P2P.CheckingPeer),
                                        count(*) filter (where new."Check" = Checks.ID)
                                    ]
                                from P2P left join Checks
                                    on P2P."Check" = Checks.ID
                            );
begin
    if (values[1] % 2 != 0 and new.State = 'Start' or
            values[1] % 2 = 0 and new.State != 'Start') then
        return null;
    elsif (values[2] >= 2) then
        return null;
    else
        return new;
    end if;
end;
$$ language plpgsql;

-- To avoid duplicates for CheckingPeer-CheckedPeer pair --
create or replace function trg_fnc_transferred_points_insert() returns trigger as
$$
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
end;
$$ language plpgsql;

-- Check if peer's TimeTracking status is not equal to new's one --
create or replace function trg_fnc_time_tracking_insert() returns trigger as
$$
declare
    last_status int :=  (
                            select
                                State
                            from TimeTracking
                            where TimeTracking.Peer = new.Peer
                            order by Date desc, Time desc
                            limit 1
                        );
begin
    if (last_status = new.State) then
        return null;
    else
        return new;
    end if;
end;
$$ language plpgsql;

-- Check if peer completed parent task --
create or replace function trg_fnc_checks_insert() returns trigger as
$$
declare
    declare ParentTask varchar :=   (
                                        select
                                            ParentTask
                                        from Tasks
                                        where Title = new.Task
                                    );
begin
    if (ParentTask is null) then
        return new;
    elsif   (
                select
                    count(*)
                from P2P
                    join Checks on P2P."Check" = Checks.ID
                    join Verter on Verter."Check" = Checks.ID
                where
                    Checks.Peer = new.Peer and
                    Checks.Task = ParentTask and
                    P2P.State = 'Success' and
                        (Verter.State = 'Success' or Verter.State is null)
            ) = 0 then
        return null;
    else
        return new;
    end if;
end;
$$ language plpgsql;


/*** Triggers ***/
create trigger trg_verter_successful_checks
before insert on Verter
for each row
execute procedure trg_fnc_successful_checks();

create trigger trg_xp_successful_checks
before insert on XP
for each row
execute procedure trg_fnc_successful_checks();

create trigger trg_p2p_insert_1
before insert on P2P
for each row
execute procedure trg_fnc_p2p_insert_1();

create trigger trg_p2p_insert_2
before insert on P2P
for each row
execute procedure trg_fnc_p2p_insert_2();

create trigger trg_transferred_points_insert
before insert on TransferredPoints
for each row
execute procedure trg_fnc_transferred_points_insert();

create trigger trg_time_tracking_insert
before insert on TimeTracking
for each row
execute procedure trg_fnc_time_tracking_insert();

create trigger trg_checks_insert
before insert on Checks
for each row
execute procedure trg_fnc_checks_insert();


/*** IO procedures ***/
-- Peers
create or replace procedure peers_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'Peers', 'peers.cvs');
end;
$$ language plpgsql;
create or replace procedure peers_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'Peers', 'peers.cvs');
end;
$$ language plpgsql;

-- Tasks
create or replace procedure tasks_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'Tasks', 'tasks.cvs');
end;
$$ language plpgsql;
create or replace procedure tasks_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'Tasks', 'tasks.cvs');
end;
$$ language plpgsql;

-- Checks
create or replace procedure checks_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'Checks', 'checks.cvs');
end;
$$ language plpgsql;
create or replace procedure checks_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'Checks', 'checks.cvs');
end;
$$ language plpgsql;

-- P2P
create or replace procedure p2p_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'P2P', 'p2p.cvs');
end;
$$ language plpgsql;
create or replace procedure p2p_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'P2P', 'p2p.cvs');
end;
$$ language plpgsql;

-- Verter
create or replace procedure verter_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'Verter', 'verter.cvs');
end;
$$ language plpgsql;
create or replace procedure verter_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'Verter', 'verter.cvs');
end;
$$ language plpgsql;

-- TransferredPoints
create or replace procedure transferred_points_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'TransferredPoints', 'transferred_points.cvs');
end;
$$ language plpgsql;
create or replace procedure transferred_points_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'TransferredPoints', 'transferred_points.cvs');
end;
$$ language plpgsql;

-- Friends
create or replace procedure friends_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'Friends', 'friends.cvs');
end;
$$ language plpgsql;
create or replace procedure friends_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'Friends', 'friends.cvs');
end;
$$ language plpgsql;

-- Recommendations
create or replace procedure recommendations_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'Recommendations', 'recommendations.cvs');
end;
$$ language plpgsql;
create or replace procedure recommendations_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'Recommendations', 'recommendations.cvs');
end;
$$ language plpgsql;

-- XP
create or replace procedure xp_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'XP', 'xp.cvs');
end;
$$ language plpgsql;
create or replace procedure xp_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'XP', 'xp.cvs');
end;
$$ language plpgsql;

-- TimeTracking
create or replace procedure timetracking_tofile(sep char default ',') as
$$
begin
    call save_to_file(sep, 'TimeTracking', 'time_tracking.cvs');
end;
$$ language plpgsql;
create or replace procedure timetracking_fromfile(sep char default ',') as
$$
begin
    call read_from_file(sep, 'TimeTracking', 'time_tracking.cvs');
end;
$$ language plpgsql;
