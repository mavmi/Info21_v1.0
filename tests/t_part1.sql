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
