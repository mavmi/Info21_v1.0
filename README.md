### TO-DO
- [x] There must be one task in the table that has no entry condition (i.e., the ParentTask field is null).

- [x] Write a part1.sql script that creates the database and all the tables described above.

- [x] Also, add procedures to the script that allow you to import and export data for each table from/to a file with a .csv extension.
The csv file separator is specified as a parameter of each procedure.

- [x] In each of the tables, enter at least 5 records.
As you progress through the task, you will need new data to test all of your choices.

- [x] This new data needs to be added to this script as well.
If csv files were used to add data to the tables, they must also be uploaded to the GIT repository

- [ ] All tasks must be named in the format of names for School 21, for example A5_s21_memory.
In the future, Whether a task belongs to a block will be determined by the name of the block in the task name, e.g. "CPP3_SmartCalc_v2.0" belongs to the CPP block. *

- [x] The P2P table cannot contain more than one incomplete P2P check related to a specific task, a peer and a checking peer.

- [x] Сheck by Verter can only refer to those checks in the Checks table that already include a successful P2P check.

- [x] XP table: The first field of this table can only refer to successful checks.

- [x] Additional args for procedures: root dir, default separator.

- [x] [part1/TimeTracking] Add TRIGGER limit for adding peer with state 2 if there not was  status 1 for this peer. And add limit for adding one peer with state 1 more that one time

- [x] [part1/P2P] Add TRIGGER for not be able to add P2P review with same Checks for different reviews

- [x] [part1/Check] Add TRIGGER for not be able to add Check to Task if the guy didn't do ParentTask of this task

- [x] [part1/P2P] Add TRIGGER for not be able to add different checking peer for Start and Success/Failure for one Check

- [ ] [part1/Friends] Add TRIGGER for not be able to add the same friends pairs: 'Gabriel' - 'Luisi', 'Luisi' - 'Gabriel'

- [ ] [part1/Friends] Add TRIGGER for not be able to add yourself to friends

- [ ] [part1/Recomendation] Add TRIGGER for not be able to add the same recomendation pair pairs: 'Gabriel' - 'Luisi', 'Gabriel' - 'Luisi'

- [ ] [part1/Recomendation] Add TRIGGER for not be able to add yourself to recomendation

- [ ] Maybe, create one file which will call all helpfull sql scripts?

- [ ] Add utils function which will return next id of coming as argument

- [ ] [recreate..Db.sql] ?Delete? '\c pmaryjo'


**To do some inserting to part1's tables for correct testing part3:**

- [x] [TransferredPoints] insert same communications? for example: 'peer1'-'peer2', 'peer1'-'peer2', 'peer2'-'peer1', 'peer1'-'peer2'
- [x] [succsessfull_pasted] add successful passing of same task and same peer
- [x] [TimeTracking] insert peers which stated in campuse for the whole day (24 hours)
- [x] [P2P]
	- insert Success passing which should not have Verter checking
	- insert Starts which still don't end (has not Success/Failure)
	- insert checks which different duration between Start and Success/Failure
- [x] [Checks]
	- more checks of one tasks to one day: '2023-01-01' - 'CPP1', '2023-01-01' - 'CPP2', '2023-01-01' - 'CPP3', '2023-01-01' - 'CPP1', '2023-01-01' - 'CPP1'
	- same numbers of checks of one task: four checks of 'CPP1' and 'CPP2' on one day
- [x] [Tasks] Add some blocks besides CPP
- [x] [Some tables] peers which completed the whole given block of tasks
- [ ] [Verter] Add normal time for Verter


**Create db for bounse part:**
- [ ] Some tables with names:
	- 'TableName'
	- the names are starting with 'TableName'
	- 'TableName' in the center/end of name
- [ ] Some scalar functions:
	- with paramethers
	- without paramethers
	- with one substring in name
	- without same substring in name
- [ ] Some triggers:
	- DDL
	- DML
- [ ] Some procedure:
	- with one substring in name
	- without same substring in name



**Need to talk about this moments:**

- [x] [part3/ex2/fnc_successfully_passed_tasks] [part3/ex4/prcdr_passed_state_percentage] Do we need to add all successfully passed tasks from Verter or from P2P? I think there should be union of P2P and Verter

- [x] [part3/ex4/prcdr_passed_state_percentage] how we can do the procedure there if it's select statement



### Just in case for be remembering:
The **DDL** (Data Definition Language) commands are used to define the database. Example: CREATE, DROP, ALTER, TRUNCATE, COMMENT, RENAME.
The **DML** (Data Manipulation Language) commands deal with the manipulation of data present in the database. Example: SELECT, INSERT, UPDATE, DELETE.
The **DCL** (Data Control Language) commands deal with the permissions, rights and other controls of the database system. Example: GRANT, INVOKE.
The **TCL** (Transaction Control Language) commands deal with the transaction of the database.Example: BEGIN, COMMIT, ROLLBACK.
