------------
-- Tables --
------------

create table if not exists TableName(
	TNColumnBigint bigint primary key,
	TNColumnVarchar varchar
);

create table if not exists TableName1(
	TN1ColumnBigint bigint primary key,
	TN1ColumnVarchar varchar
);

create table if not exists TableName2(
	TN2ColumnBigint bigint primary key,
	TN2ColumnVarchar varchar
);

create table if not exists TableNameAnother(
	TNAColumnInt int,
	TNAColumnVarchar varchar,
	TNAColumnDate date
);

create table if not exists PlusTableOne(
	PTOColumnInt int,
	PTOColumnVarchar varchar,
	PTOColumnTime time
);

create table if not exists PlusAnotherOneTableName(
	PTNOTNColumnInt int,
	PTNOTNColumnVarchar varchar,
	PTNOTNColumnTime date
	PTNOTNColumnTime time
);

create table if not exists PlusAnother(
	PAColumnInt bigint primary key,
	PAColumnVarchar varchar,
	PAColumnTime date
	PAColumnTime time
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

create or replace function fnc_with_params_sub(
	number1 int,
	number2 int
) returns bigint as
$$
begin
	return (number1 - number2);
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

create or replace function trg_comment() returns trigger as
$$
begin
	alter
end;
$$ language plpgsql;
