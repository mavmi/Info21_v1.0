do
$insert_current_peers_visities$
begin
	/* Yesterday visities */

	-- minuse 1 day & 8:03
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '1 day 483 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 483 minute')::time,
		1
	);
	-- minuse 1 day & 8:00
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '1 day 300 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 300 minute')::time,
		2
	);

	-- minuse 1 day & 5:13
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Gabriel',
		(LOCALTIMESTAMP - interval '1 day 313 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 313 minute')::time,
		1
	);
	-- minuse 1 day & 3:04
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Gabriel',
		(LOCALTIMESTAMP - interval '1 day 184 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 184 minute')::time,
		2
	);

	-- minuse 1 day & 4:17
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '1 day 257 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 257 minute')::time,
		1
	);
	-- minuse 1 day & 0:30
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '1 day 30 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 30 minute')::time,
		2
	);

	-- minuse 1 day & 3:39
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Luisi',
		(LOCALTIMESTAMP - interval '1 day 219 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 219 minute')::time,
		1
	);
	-- minuse 1 day & 0:30
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Luisi',
		(LOCALTIMESTAMP - interval '1 day 30 minute')::date,
		(LOCALTIMESTAMP(0) - interval '1 day 30 minute')::time,
		2
	);

	/* Today visities */

	-- minuse 15:03
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '903 minute')::date,
		(LOCALTIMESTAMP(0) - interval '903 minute')::time,
		1
	);
	-- minuse 8:00
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '300 minute')::date,
		(LOCALTIMESTAMP(0) - interval '300 minute')::time,
		2
	);


	-- minuse 5:13
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '313 minute')::date,
		(LOCALTIMESTAMP(0) - interval '313 minute')::time,
		1
	);
	-- minuse 3:04
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Near_Muslim',
		(LOCALTIMESTAMP - interval '184 minute')::date,
		(LOCALTIMESTAMP(0) - interval '184 minute')::time,
		2
	);

	-- minuse 4:17
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '257 minute')::date,
		(LOCALTIMESTAMP(0) - interval '257 minute')::time,
		1
	);
	-- minuse 0:30
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Pirate',
		(LOCALTIMESTAMP - interval '30 minute')::date,
		(LOCALTIMESTAMP(0) - interval '30 minute')::time,
		2
	);

	-- minuse 6:37
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '397 minute')::date,
		(LOCALTIMESTAMP(0) - interval '397 minute')::time,
		1
	);
	-- minuse 3:21
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Strangler',
		(LOCALTIMESTAMP - interval '201 minute')::date,
		(LOCALTIMESTAMP(0) - interval '201 minute')::time,
		2
	);

	-- minuse 6:34 (still at school)
	insert into TimeTracking values(
		fnc_next_id('TimeTracking'),
		'Luisi',
		(LOCALTIMESTAMP - interval '700 minute')::date,
		(LOCALTIMESTAMP(0) - interval '700 minute')::time,
		1
	);
end
$insert_current_peers_visities$;
