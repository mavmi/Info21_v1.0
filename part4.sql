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
