### TO-DO
- ~~There must be one task in the table that has no entry condition (i.e., the ParentTask field is null).~~

- ~~Write a part1.sql script that creates the database and all the tables described above.~~

- ~~Also, add procedures to the script that allow you to import and export data for each table from/to a file with a .csv extension.
The csv file separator is specified as a parameter of each procedure.~~

- ~~In each of the tables, enter at least 5 records.
As you progress through the task, you will need new data to test all of your choices.~~

- ~~This new data needs to be added to this script as well.
If csv files were used to add data to the tables, they must also be uploaded to the GIT repository.~~

- All tasks must be named in the format of names for School 21, for example A5_s21_memory.
In the future, Whether a task belongs to a block will be determined by the name of the block in the task name, e.g. "CPP3_SmartCalc_v2.0" belongs to the CPP block. *

- ~~The P2P table cannot contain more than one incomplete P2P check related to a specific task, a peer and a checking peer.~~

- ~~Сheck by Verter can only refer to those checks in the Checks table that already include a successful P2P check.~~

- ~~XP table: The first field of this table can only refer to successful checks.~~

- ~~Additional args for procedures: root dir, default separator.~~

- ~~[part1/TimeTracking] Add TRIGGER limit for adding peer with state 2 if there not was  status 1 for this peer. And add limit for adding one peer with state 1 more that one time~~

- ~~[part1/P2P] Add TRIGGER for not be able to add P2P review with same Checks for different reviews~~

- [part1/Check] Add TRIGGER for not be able to add Check to Task if the guy didn't do ParentTask of this task

- [part1/P2P] Add TRIGGER for not be able to add different checking peer for Start and Success/Failure for one Check

- Maybe, create one file which will call all helpfull sql scripts?

- Add utils function which will return next id of coming as argument


**To do some inserting to part1's tables for correct testing part3:**

	COMPLETED 1. [TransferredPoints] insert same communications? for example: 'peer1'-'peer2', 'peer1'-'peer2', 'peer2'-'peer1', 'peer1'-'peer2'
	2. [succsessfull_pasted] add successful passing of same task and same peer
	3. [TimeTracking] insert peers which stated in campuse for the whole day (24 hours)
	COMPLETED 4. [P2P]
		- insert Success passing which should not have Verter checking
		- insert Starts which still don't end (has not Success/Failure)
		- insert checks which different duration between Start and Success/Failure
	COMPLETED 5. [Checks]
		- more checks of one tasks to one day: '2023-01-01' - 'CPP1', '2023-01-01' - 'CPP2', '2023-01-01' - 'CPP3', '2023-01-01' - 'CPP1', '2023-01-01' - 'CPP1'
		- same numbers of checks of one task: four checks of 'CPP1' and 'CPP2' on one day
	COMPLETED 6. [Tasks] Add some blocks besides CPP
	7. [Some tables] peers which completed the whole given block of tasks



### Need to talk about this moments:

- [part3/ex2/fnc_successfully_passed_tasks] [part3/ex4/prcdr_passed_state_percentage] Do we need to add all successfully passed tasks from Verter or from P2P? I think there should be union of P2P and Verter

- [part3/ex4/prcdr_passed_state_percentage] how we can do the procedure there if it's select statement
