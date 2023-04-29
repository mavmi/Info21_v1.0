------------
-- Tables --
------------

create table if not exists TableName(
	id bigint primary key,
	TNColumnVarchar varchar
);

create table if not exists TableName1(
	id bigint primary key,
	TN1ColumnVarchar varchar
);

create table if not exists TableName2(
	id bigint primary key,
	TN2ColumnVarchar varchar
);

create table if not exists TableNameAnother(
	id int,
	TNAColumnVarchar varchar,
	TNAColumnDate date
);

create table if not exists PlusTableOne(
	id int,
	PTOColumnVarchar varchar,
	PTOColumnTime time
);

create table if not exists PlusAnotherOneTableName(
	id int,
	PTNOTNColumnVarchar varchar,
	PTNOTNColumnTime time,
	PTNOTNColumnDate date
);

create table if not exists PlusAnother(
	id bigint primary key,
	PAColumnVarchar varchar,
	PAColumnTime time,
	PAColumnDate date
);


---------------
-- Functions --
---------------

create or replace function fnc_without_params() returns bigint as
$$
begin
	return 0;
end;
$$ language plpgsql;

create or replace function fnc_without_params1() returns bigint as
$$
begin
	return 0;
end;
$$ language plpgsql;

create or replace function f_w_p() returns bigint as
$$
begin
	return 1;
end;
$$ language plpgsql;

create or replace function f_w_p1() returns bigint as
$$
begin
	return 1;
end;
$$ language plpgsql;

create or replace function fnc_with_params_sum(
	number1 int,
	number2 int
) returns bigint as
$$
begin
	return (number1 + number2);
end;
$$ language plpgsql;

create or replace function fnc_with_params_sub(
	number1 int,
	number2 int
) returns bigint as
$$
begin
	return (number1 - number2);
end;
$$ language plpgsql;

create or replace function fwp_sum(
	number1 int,
	number2 int,
	number3 int
) returns bigint as
$$
begin
	return (number1 + number2 + number3);
end;
$$ language plpgsql;

create or replace function another_name_with(
	number1 int
) returns bigint as
$$
begin
	return number1;
end;
$$ language plpgsql;

create or replace function other_without() returns bigint as
$$
begin
	return 0*1;
end;
$$ language plpgsql;


--------------
-- Triggers --
--------------

-- DDL triggers
create or replace function trg_no_alter_TableName()
returns event_trigger as
$$
declare
	obj record;
begin
	perform *
	from pg_catalog.pg_event_trigger_drop_objects()
	where object_name = 'TableName';

	if found then
		for obj in select * from pg_event_trigger_ddl_commands()
		loop
			raise exception
				'Abort %: % may not be changed',
				obj.command_tag,
				obj.object_type;
		end loop;
	end if;
end;
$$ language plpgsql;

create event trigger trg_ddl_no_alter_TableName
on ddl_command_end when tag in ('ALTER TABLE')
execute procedure trg_no_alter_TableName();


create or replace function trg_no_comments()
returns event_trigger as
$$
declare
	obj record;
begin
	for obj in select * from pg_event_trigger_ddl_commands()
	loop
		raise exception
			'Abort %: % may not be commented',
			obj.command_tag,
			obj.object_type;
	end loop;
end;
$$ language plpgsql;

create event trigger trg_ddl_no_comments
on ddl_command_end when tag in ('COMMENT')
execute procedure trg_no_comments();
--


-- DML triggers
create or replace function trg_fnc_check_id() returns trigger as
$$
begin
	if (new.id in (select id from TableNameAnother))
		then return null;
	end if;
	return new;
end;
$$ language plpgsql;

create trigger trg_dml_check_id
before insert on TableNameAnother
for each row
execute procedure trg_fnc_check_id();


create or replace function trg_fnc_udate() returns trigger as
$$
begin
	insert into TableName2(TN2ColumnBigint, TN2ColumnVarchar)
		values (fnc_next_id('TableName2'), new.PTOColumnVarchar);
	return new;
end;
$$ language plpgsql;

create trigger trg_dml_update
after update on PlusTableOne
for each row
execute procedure trg_fnc_udate();


create or replace function trg_fnc_delete() returns trigger as
$$
begin
	insert into TableName1(TN2ColumnBigint, TN2ColumnVarchar)
		values (fnc_next_id('TableName1'), new.PAColumnVarchar);
	return new;
end;
$$ language plpgsql;

create trigger trg_dml_delete
after delete on PlusAnother
for each row
execute procedure trg_fnc_delete();
--


----------------
-- Procedures --
----------------

create or replace procedure insert_into_TableName() as
$$
begin
	insert into TableName values (fnc_next_id('TableName'), 'TNtext1');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext2');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext3');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext4');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext5');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext6');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext7');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext8');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext9');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext10');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext11');
	insert into TableName values (fnc_next_id('TableName'), 'TNtext12');

	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text1');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text2');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text3');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text4');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text5');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text6');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text7');
	insert into TableName1 values (fnc_next_id('TableName1'), 'TN1text8');

	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text1');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text2');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text3');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text4');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text5');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text6');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text7');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text8');
	insert into TableName2 values (fnc_next_id('TableName2'), 'TN2text9');
end;
$$ language plpgsql;


create or replace procedure in_TableNameAnother() as
$$
begin
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext1', '2023-03-01');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext2', '2023-03-02');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext3', '2023-03-03');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext4', '2023-03-04');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext5', '2023-03-05');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext6', '2023-03-06');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext7', '2023-03-07');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext8', '2023-03-08');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext9', '2023-03-09');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext10', '2023-03-10');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext11', '2023-03-11');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext12', '2023-03-12');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext13', '2023-03-13');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext14', '2023-03-14');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext15', '2023-03-15');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext16', '2023-03-16');
	insert into TableNameAnother values (fnc_next_id('TableNameAnother'), 'TNAtext17', '2023-03-17');
end;
$$ language plpgsql;


create or replace procedure insert_into_PlusTableOne() as
$$
begin
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext1', '00:21:01');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext2', '01:21:02');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext3', '02:21:03');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext4', '03:21:04');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext5', '04:21:05');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext6', '05:21:06');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext7', '06:21:07');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext8', '07:21:08');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext9', '08:21:09');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext10', '09:21:10');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext11', '10:21:11');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext12', '11:21:12');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext13', '12:21:13');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext14', '13:21:14');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext15', '14:21:15');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext16', '15:21:16');
	insert into PlusTableOne values (fnc_next_id('PlusTableOne'), 'PTOtext17', '16:21:17');
end;
$$ language plpgsql;


create or replace procedure ins_int_PlusAnotherOneTableName() as
$$
begin
	insert into PlusAnotherOneTableName values (
		fnc_next_id('PlusAnotherOneTableName'),
		'PTNOTNtext1',
		'00:21:08',
		'2023-02-01'
	);
	insert into PlusAnotherOneTableName values (
		fnc_next_id('PlusAnotherOneTableName'),
		'PTNOTNtext2',
		'01:21:08',
		'2023-02-02'
	);
	insert into PlusAnotherOneTableName values (
		fnc_next_id('PlusAnotherOneTableName'),
		'PTNOTNtext3',
		'02:21:08',
		'2023-02-03'
	);
	insert into PlusAnotherOneTableName values (
		fnc_next_id('PlusAnotherOneTableName'),
		'PTNOTNtext4',
		'03:21:08',
		'2023-02-04'
	);
	insert into PlusAnotherOneTableName values (
		fnc_next_id('PlusAnotherOneTableName'),
		'PTNOTNtext5',
		'04:21:08',
		'2023-02-05'
	);
	insert into PlusAnotherOneTableName values (
		fnc_next_id('PlusAnotherOneTableName'),
		'PTNOTNtext6',
		'05:21:08',
		'2023-02-06'
	);
end;
$$ language plpgsql;


create or replace procedure PA_procedure() as
$$
begin
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext1',
		'00:42:21',
		'2023-01-01'
	);
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext2',
		'01:42:21',
		'2023-01-02'
	);
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext3',
		'02:42:21',
		'2023-01-03'
	);
end
$$ language plpgsql;


create or replace procedure prcdr_PA1() as
$$
begin
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext4',
		'03:42:21',
		'2023-01-04'
	);
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext5',
		'04:42:21',
		'2023-01-05'
	);
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext6',
		'05:42:21',
		'2023-01-06'
	);
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext7',
		'06:42:21',
		'2023-01-07'
	);
	insert into PlusAnother values (
		fnc_next_id('PlusAnother'),
		'PACtext8',
		'07:42:21',
		'2023-01-08'
	);
end;
$$ language plpgsql;


call insert_into_TableName();
call in_TableNameAnother();
call insert_into_PlusTableOne();
call ins_int_PlusAnotherOneTableName();
call PA_procedure();
call prcdr_PA1();
