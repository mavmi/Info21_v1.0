\c pmaryjo;
select pg_terminate_backend(pid) from pg_stat_activity where datname='info21_bonus';
drop database info21_bonus;
create database info21_bonus;
\c info21_bonus;
