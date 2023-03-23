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
create or replace procedure drop_tables_started_TableName() as
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
-- call drop_tables_started_TableName();
