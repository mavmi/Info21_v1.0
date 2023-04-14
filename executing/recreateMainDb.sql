\c postgres;
select pg_terminate_backend(pid) from pg_stat_activity where datname='info21';
drop database info21;
create database info21;
\c info21;
