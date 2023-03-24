-----------------------
-- SETTING VARIABLES --
-----------------------
\set recreating_db_path executing/recreateBonusDB.sql
\set filling_db_path utils/u_part4.sql

-------------------------------------
-- CREATING OR REFRESHING DATABASE --
-------------------------------------
\i :recreating_db_path

----------------------
-- FILLING DATABASE --
----------------------
\i :filling_db_path


----------------
-- PROCEDURES --
----------------

/*
 * 1)
 * Drop all those tables whose names begin with the phrase 'TableName'
 */
create or replace procedure prcdr_drop_tables_started_TableName() as
$$
declare
	rec record;
begin
	for rec in
		select tablename
		from pg_catalog.pg_tables
		where schemaname != 'pg_catalog'
			and schemaname != 'information_schema'
			and tablename ~* '^TableName'
	loop
		execute 'drop table ' || quote_ident(rec.tablename);
		raise info 'Dropped table: %', quote_ident(rec.tablename);
	end loop;
end;
$$ language plpgsql;

-- CALL PROCEDURE --
-- call prcdr_drop_tables_started_TableName();


/*
 * 2)
 * Output a list of functions' names with their parameters
 * and number of found funcs (just functions which have params)
 */
create or replace procedure prcdr_funcs_with_arguments(
	funcs inout text,
	numb inout int
) as
$$
declare
	line record;
begin
	for line in select (
				p.proname || ' (' || pg_get_function_arguments(p.oid) || ')'
			) as functions_list
		from pg_catalog.pg_namespace n
			join pg_catalog.pg_proc p on p.pronamespace = n.oid
		where p.prokind = 'f'
			and n.nspname = 'public'
			and (pg_get_function_arguments(p.oid) = '') is not true
		loop
		funcs := (funcs || line.functions_list || E'\n');
		numb := numb + 1;
	end loop;
end;
$$ language plpgsql;

-- CALL PROCEDURE --
-- call prcdr_funcs_with_arguments('', 0);
