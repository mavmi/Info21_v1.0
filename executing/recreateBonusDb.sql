\c postgres;
select pg_terminate_backend(pid) from pg_stat_activity where datname='info21_bonus';
drop database info21_bonus;
create database info21_bonus;
\c info21_bonus;

\i ../utils/u_main.sql;
\i ../part1.sql;
\i ../utils/u_part2-part3.sql;
\i ../part2.sql;
\i ../part3.sql;
\i ../utils/u_part4.sql;
\i ../part4.sql;
