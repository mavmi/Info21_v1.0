----------------------------------
-- trg_verter_successful_checks --
----------------------------------
begin;
do $$
    declare
        rows_count int;
        new_check_id bigint;
    begin
        new_check_id = fnc_next_id('Checks');
        insert into Checks values(new_check_id, 'Sprat_eater', 'DO2', '2023-03-09');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '17:21:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Success', '18:11:03');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Start', '18:11:11');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Success', '18:12:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
    end;
$$ language plpgsql;
rollback;

begin;
do $$
    declare
        rows_count int;
        new_check_id bigint;
    begin
        new_check_id = fnc_next_id('Checks');
        insert into Checks values(new_check_id, 'Sprat_eater', 'DO2', '2023-03-09');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '17:21:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Failure', '18:11:03');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Start', '18:11:11');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Success', '18:12:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);
    end;
$$ language plpgsql;
rollback;


------------------------------
-- trg_xp_successful_checks --
------------------------------
begin;
do $$
    declare
        rows_count int;
        new_check_id bigint;
    begin
        new_check_id = fnc_next_id('Checks');
        insert into Checks values(new_check_id, 'Sprat_eater', 'DO2', '2023-03-09');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '17:21:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Success', '18:11:03');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Start', '18:11:11');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Success', '18:12:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into XP values(fnc_next_id('XP'), new_check_id, 250);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
    end;
$$ language plpgsql;
rollback;

begin;
do $$
    declare
        rows_count int;
        new_check_id bigint;
    begin
        new_check_id = fnc_next_id('Checks');
        insert into Checks values(new_check_id, 'Sprat_eater', 'DO2', '2023-03-09');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '17:21:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Success', '18:11:03');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Start', '18:11:11');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Verter values(fnc_next_id('Verter'), new_check_id, 'Failure', '18:12:42');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into XP values(fnc_next_id('XP'), new_check_id, 250);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);
    end;
$$ language plpgsql;
rollback;


----------------------
-- trg_p2p_insert_1 --
----------------------
begin;
do $$
    declare
        rows_count int;
        new_check_id bigint := fnc_next_id('Checks');
    begin
        insert into Checks values(new_check_id, 'Sprat_eater', 'DO2', '2023-03-09');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Pirate', 'Failure', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Pirate', 'Success', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Success', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Failure', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);
    end;
$$ language plpgsql;
rollback;


----------------------
-- trg_p2p_insert_2 --
----------------------
begin;
do $$
    declare
        rows_count int;
        new_check_id bigint := fnc_next_id('Checks');
    begin
        insert into Checks values(new_check_id, 'Sprat_eater', 'DO2', '2023-03-09');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Start', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Success', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), new_check_id, 'Wolf', 'Failure', '14:21:36');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);
    end;
$$ language plpgsql;
rollback;


-----------------------------------
-- trg_transferred_points_insert --
-----------------------------------
begin;
do $$
    declare
        points_amount int := 123;
        id1 bigint := fnc_next_id('TransferredPoints');
        id2 bigint := fnc_next_id('TransferredPoints');
    begin
        insert into TransferredPoints values(id1, 'Luisi', 'Sprat_eater', points_amount);
        assert (
                (select PointsAmount
                 from TransferredPoints
                 where id = id1) = points_amount
            );

        insert into TransferredPoints values(id2, 'Luisi', 'Sprat_eater', points_amount);
        assert (
                (select PointsAmount
                 from TransferredPoints
                 where id = id1) = points_amount + 1
            );
    end;
$$ language plpgsql;
rollback;


------------------------------
-- trg_time_tracking_insert --
------------------------------
begin;
do $$
    declare
        rows_count int;
    begin
        insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2024-01-01', '12:12:12', 1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2024-01-01', '13:13:13', 1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2024-01-01', '14:14:14', 2);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2024-01-01', '15:15:15', 2);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into TimeTracking values(fnc_next_id('TimeTracking'), 'Wolf', '2024-01-01', '16:16:16', 1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
    end;
$$ language plpgsql;
rollback;


-----------------------
-- trg_checks_insert --
-----------------------
begin;
do $$
    declare
        peer_name varchar := 'username';
        rows_count int;
        check_id int;
    begin
        insert into Peers values(peer_name, '06-01-1996');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Checks values(fnc_next_id('Checks'), peer_name, 'CPP5', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Checks values(fnc_next_id('Checks'), peer_name, 'CPP4', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Checks values(fnc_next_id('Checks'), peer_name, 'CPP3', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Checks values(fnc_next_id('Checks'), peer_name, 'CPP2', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, peer_name, 'CPP1', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Checks values(fnc_next_id('Checks'), peer_name, 'CPP2', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into P2P values(fnc_next_id('P2P'), check_id, 'Wolf', 'Start', '12:12:12');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
        insert into P2P values(fnc_next_id('P2P'), check_id, 'Wolf', 'Success', '13:13:13');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
        insert into Verter values(fnc_next_id('Verter'), check_id, 'Start', '14:14:14');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
        insert into Verter values(fnc_next_id('Verter'), check_id, 'Success', '15:15:15');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        check_id = fnc_next_id('Checks');
        insert into Checks values(check_id, peer_name, 'CPP2', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into P2P values(fnc_next_id('P2P'), check_id, 'Wolf', 'Start', '16:16:16');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
        insert into P2P values(fnc_next_id('P2P'), check_id, 'Wolf', 'Success', '17:17:17');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Checks values(fnc_next_id('Checks'), peer_name, 'CPP3', '2024-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);
    end;
$$ language plpgsql;
rollback;


------------------------
-- trg_friends_insert --
------------------------
begin;
do $$
    declare
        rows_count int;
        name1 varchar := 'username1';
        name2 varchar := 'username2';
    begin
        insert into Peers values(name1, '2000-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Peers values(name2, '2000-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Friends values(fnc_next_id('Friends'), name1, name2);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Friends values(fnc_next_id('Friends'), name1, name2);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Friends values(fnc_next_id('Friends'), name2, name1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Friends values(fnc_next_id('Friends'), name1, name1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);
    end;
$$ language plpgsql;
rollback;


--------------------------------
-- trg_recommendations_insert --
--------------------------------
begin;
do $$
    declare
        rows_count int;
        name1 varchar := 'username1';
        name2 varchar := 'username2';
    begin
        insert into Peers values(name1, '2000-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Peers values(name2, '2000-01-01');
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Recommendations values(fnc_next_id('Recommendations'), name1, name2);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Recommendations values(fnc_next_id('Recommendations'), name1, name2);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Recommendations values(fnc_next_id('Recommendations'), name2, name1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 1);

        insert into Recommendations values(fnc_next_id('Recommendations'), name2, name1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);

        insert into Recommendations values(fnc_next_id('Recommendations'), name1, name1);
        get diagnostics rows_count = row_count;
        assert (rows_count = 0);
    end;
$$ language plpgsql;
rollback;
