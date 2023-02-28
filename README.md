### TO-DO
- ~~There must be one task in the table that has no entry condition (i.e., the ParentTask field is null).~~

- ~~Write a part1.sql script that creates the database and all the tables described above.~~

- ~~Also, add procedures to the script that allow you to import and export data for each table from/to a file with a .csv extension. 
The csv file separator is specified as a parameter of each procedure.~~

- ~~In each of the tables, enter at least 5 records.
As you progress through the task, you will need new data to test all of your choices.~~

- This new data needs to be added to this script as well.
If csv files were used to add data to the tables, they must also be uploaded to the GIT repository.

- All tasks must be named in the format of names for School 21, for example A5_s21_memory. 
In the future, Whether a task belongs to a block will be determined by the name of the block in the task name, e.g. "CPP3_SmartCalc_v2.0" belongs to the CPP block. *

- The P2P table cannot contain more than one incomplete P2P check related to a specific task, a peer and a checking peer. 

- Сheck by Verter can only refer to those checks in the Checks table that already include a successful P2P check.

- The first field of this table can only refer to successful checks.

- Additional args for procedures: root dir, default separator.
