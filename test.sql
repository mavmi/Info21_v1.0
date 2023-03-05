do
$$
declare
    values int array[2] :=  
                            (
                                select
                                    array[
                                        count(*),
                                        count(*) filter (where "Check" % 2 = 0)
                                    ]
                                from p2p
                            );
begin

end;
$$;
