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
        Bitrhday date
    );

    if (fill = false) then
        return;
    end if;

    insert into Peers values('Wolf', '1990-03-01');
    insert into Peers values('Sprat_eater', '1999-02-02');
    insert into Peers values('Near_Muslim', '1980-11-03');
    insert into Peers values('Pirate', '1994-04-04');
    insert into Peers values('Strangler', '2000-05-05');
    insert into Peers values('Gabriel', '1998-09-19');
    insert into Peers values('Yo_yo', '1977-06-20');
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

    insert into Checks values(1, 'Near_Muslim', 'DO1', '2022-12-01');
    insert into Checks values(2, 'Strangler', 'A1', '2022-12-01');
    insert into Checks values(3, 'Gabriel', 'A1', '202-12-01');

    insert into Checks values(4, 'Gabriel', 'A2', '2022-12-03');

    insert into Checks values(5, 'Near_Muslim', 'DO2', '2022-12-10');
    insert into Checks values(6, 'Strangler', 'A2', '2022-12-10');
    insert into Checks values(7, 'Gabriel', 'A3', '2022-12-10');

    insert into Checks values(8, 'Near_Muslim', 'DO3', '2022-12-15');
    insert into Checks values(9, 'Strangler', 'A3', '2022-12-15');
    insert into Checks values(10, 'Gabriel', 'A4', '2022-12-15');

    insert into Checks values(11, 'Near_Muslim', 'DO4', '2023-12-24');
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
    insert into Checks values(43, 'Yo_yo', 'SQL1', '2023-02-27');
    insert into Checks values(44, 'Gabriel', 'SQL1', '2023-02-27');
    insert into Checks values(45, 'Wolf', 'CPP5', '2023-02-27');

    insert into Checks values(46, 'Gabriel', 'SQL2', '2023-03-01');
    insert into Checks values(47, 'Yo_yo', 'SQL2', '2023-03-01');

    insert into Checks values(48, 'Yo_yo', 'SQL3', '2023-03-05');

    insert into Checks values(49, 'Yo_yo', 'SQL3', '2023-03-06');

    insert into Checks values(50, 'Yo_yo', 'SQL3', '2023-03-07');
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

    insert into P2P values(fnc_next_id('P2P'), 1, 'Near_Muslim', 'Start', '16:00:57');
    insert into P2P values(fnc_next_id('P2P'), 1, 'Near_Muslim', 'Success', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 2, 'Strangler', 'Start', '16:18:57');
    insert into P2P values(fnc_next_id('P2P'), 2, 'Strangler', 'Success', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 3, 'Gabriel', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 3, 'Gabriel', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 4, 'Gabriel', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 4, 'Gabriel', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 5, 'Near_Muslim', 'Start', '15:16:17');
    insert into P2P values(fnc_next_id('P2P'), 5, 'Near_Muslim', 'Success', '16:17:18');

    insert into P2P values(fnc_next_id('P2P'), 6, 'Strangler', 'Start', '18:15:20');
    insert into P2P values(fnc_next_id('P2P'), 6, 'Strangler', 'Success', '19:15:21');

    insert into P2P values(fnc_next_id('P2P'), 7, 'Gabriel', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 7, 'Gabriel', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 8, 'Near_Muslim', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 8, 'Near_Muslim', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 9, 'Strangler', 'Start', '10:19:20');
    insert into P2P values(fnc_next_id('P2P'), 9, 'Strangler', 'Success', '11:20:21');

    insert into P2P values(fnc_next_id('P2P'), 10, 'Gabriel', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 10, 'Gabriel', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 11, 'Near_Muslim', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 11, 'Near_Muslim', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 12, 'Strangler', 'Start', '18:19:20');
    insert into P2P values(fnc_next_id('P2P'), 12, 'Strangler', 'Success', '19:20:21');

    insert into P2P values(fnc_next_id('P2P'), 13, 'Gabriel', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 13, 'Gabriel', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 14, 'Near_Muslim', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 14, 'Near_Muslim', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 15, 'Sprat_eater', 'Start', '12:13:14');
    insert into P2P values(fnc_next_id('P2P'), 15, 'Sprat_eater', 'Failure', '13:14:15');

    insert into P2P values(fnc_next_id('P2P'), 16, 'Strangler', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 16, 'Strangler', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 17, 'Sprat_eater', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 17, 'Sprat_eater', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 18, 'Sprat_eater', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 18, 'Sprat_eater', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 19, 'Near_Muslim', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 19, 'Near_Muslim', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 20, 'Strangler', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 20, 'Strangler', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 21, 'Gabriel', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 21, 'Gabriel', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 22, 'Near_Muslim', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 22, 'Near_Muslim', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 23, 'Sprat_eater', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 23, 'Sprat_eater', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 24, 'Strangler', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 24, 'Strangler', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 25, 'Gabriel', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 25, 'Gabriel', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 26, 'Pirate', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 26, 'Pirate', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 27, 'Wolf', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 27, 'Wolf', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 28, 'Sprat_eater', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 28, 'Sprat_eater', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 29, 'Pirate', 'Start', '17:18:19');
    insert into P2P values(fnc_next_id('P2P'), 29, 'Pirate', 'Success', '18:19:20');

    insert into P2P values(fnc_next_id('P2P'), 30, 'Wolf', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 30, 'Wolf', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 31, 'Sprat_eater', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 31, 'Sprat_eater', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 32, 'Pirate', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 32, 'Pirate', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 33, 'Wolf', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 33, 'Wolf', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 34, 'Sprat_eater', 'Start', '16:00:57');

    insert into P2P values(fnc_next_id('P2P'), 35, 'Strangler', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 35, 'Strangler', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 36, 'Pirate', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 36, 'Pirate', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 37, 'Gabriel', 'Start', '16:00:57');
    insert into P2P values(fnc_next_id('P2P'), 37, 'Gabriel', 'Failure', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 38, 'Wolf', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 38, 'Wolf', 'Success', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 39, 'Wolf', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 39, 'Wolf', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 40, 'Strangler', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 40, 'Strangler', 'Success', '15:07:55');

    insert into P2P values(fnc_next_id('P2P'), 41, 'Gabriel', 'Start', '20:21:22');
    insert into P2P values(fnc_next_id('P2P'), 41, 'Gabriel', 'Success', '21:22:23');

    insert into P2P values(fnc_next_id('P2P'), 42, 'Pirate', 'Start', '15:00:40');

    insert into P2P values(fnc_next_id('P2P'), 43, 'Yo_yo', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 43, 'Yo_yo', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 44, 'Gabriel', 'Start', '19:30:21');
    insert into P2P values(fnc_next_id('P2P'), 44, 'Gabriel', 'Success', '20:00:00');

    insert into P2P values(fnc_next_id('P2P'), 45, 'Wolf', 'Start', '16:00:57');
    insert into P2P values(fnc_next_id('P2P'), 45, 'Wolf', 'Success', '17:00:25');

    insert into P2P values(fnc_next_id('P2P'), 46, 'Gabriel', 'Start', '08:01:21');
    insert into P2P values(fnc_next_id('P2P'), 46, 'Gabriel', 'Success', '08:30:02');

    insert into P2P values(fnc_next_id('P2P'), 47, 'Yo_yo', 'Start', '15:00:40');
    insert into P2P values(fnc_next_id('P2P'), 47, 'Yo_yo', 'Success', '15:26:22');

    insert into P2P values(fnc_next_id('P2P'), 48, 'Yo_yo', 'Start', '20:15:21');
    insert into P2P values(fnc_next_id('P2P'), 48, 'Yo_yo', 'Failure', '21:10:05');

    insert into P2P values(fnc_next_id('P2P'), 49, 'Yo_yo', 'Start', '21:22:23');
    insert into P2P values(fnc_next_id('P2P'), 49, 'Yo_yo', 'Failure', '22:23:24');

    insert into P2P values(fnc_next_id('P2P'), 50, 'Yo_yo', 'Start', '14:16:07');
    insert into P2P values(fnc_next_id('P2P'), 50, 'Yo_yo', 'Success', '15:07:55');
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

    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Sprat_eater', 'Wolf', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Near_Muslim', 'Sprat_eater', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Pirate', 'Near_Muslim', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Strangler', 'Pirate', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Wolf', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Sprat_eater', 'Strangler', 1);
    insert into TransferredPoints values(fnc_next_id('TransferredPoints'), 'Near_Muslim', 'Strangler', 1);
end;
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

    insert into Friends values(fnc_next_id('Friends'), 'Wolf', 'Sprat_eater');
    insert into Friends values(fnc_next_id('Friends'), 'Sprat_eater', 'Near_Muslim');
    insert into Friends values(fnc_next_id('Friends'), 'Near_Muslim', 'Pirate');
    insert into Friends values(fnc_next_id('Friends'), 'Pirate', 'Strangler');
    insert into Friends values(fnc_next_id('Friends'), 'Strangler', 'Wolf');
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
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Sprat_eater', 'Pirate');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Near_Muslim', 'Strangler');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Pirate', 'Near_Muslim');
    insert into Recommendations values(fnc_next_id('Recommendations'), 'Strangler', 'Wolf');
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
    insert into XP values(fnc_next_id('XP'), 3, 300);
    insert into XP values(fnc_next_id('XP'), 5, 300);
    insert into XP values(fnc_next_id('XP'), 6, 350);
    insert into XP values(fnc_next_id('XP'), 7, 400);
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

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2023-02-01', '11:24:11', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2023-02-01', '23:42:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2023-02-03', '09:05:54', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Near_Muslim', '2023-02-03', '23:42:00', 2);

    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Sprat_eater', '2023-02-10', '13:44:01', 1);
    insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Sprat_eater', '2023-02-10', '23:42:00', 2);
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

-- Check if new row does not duplicate P2P-check with started or finished status --
create or replace function trg_fnc_p2p_insert() returns trigger as
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


/*** Triggers ***/
create trigger trg_verter_successful_checks
before insert on Verter
for each row
execute procedure trg_fnc_successful_checks();

create trigger trg_xp_successful_checks
before insert on XP
for each row
execute procedure trg_fnc_successful_checks();

create trigger trg_p2p_insert
before insert on P2P
for each row
execute procedure trg_fnc_p2p_insert();

create trigger trg_transferred_points_insert
before insert on TransferredPoints
for each row
execute procedure trg_fnc_transferred_points_insert();

create trigger trg_time_tracking_insert
before insert on TimeTracking
for each row
execute procedure trg_fnc_time_tracking_insert();


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
