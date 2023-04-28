\c postgres;
select pg_terminate_backend(pid) from pg_stat_activity where datname='info21';
drop database info21;
create database info21;
\c info21;

\i ../utils/u_main.sql;
\i ../part1.sql;
\i ../utils/u_part2-part3.sql;
\i ../part2.sql;
\i ../part3.sql;
\i ../tests/t_part3.sql;
