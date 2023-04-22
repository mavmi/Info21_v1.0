-----------
-- print --
-----------

call fnc_print('prcdr_drop_tables_started_TableName');
call prcdr_drop_tables_started_TableName();

call fnc_print('prcdr_funcs_with_arguments');
call prcdr_funcs_with_arguments('', 0);

call fnc_print('prcdr_destroy_DML_triggers');
call prcdr_destroy_DML_triggers(0);

call fnc_print('prcdr_find_substr_in_obj');
call prcdr_find_substr_in_obj('without', 'rewrite');
