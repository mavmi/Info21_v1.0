/*
 * Return next ID for 'table_name' table
 */
create or replace procedure fnc_print(msg varchar) as
$$
begin
	raise notice '%', upper(msg);
end;
$$ language plpgsql;

create or replace function fnc_next_id(table_name varchar, out id bigint) as
$$
begin
	execute format('select coalesce(max(id) + 1, 1) from %s', table_name)
	into id;
end;
$$ language plpgsql;
