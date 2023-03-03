create or replace function func() returns int as
$$
declare
    cnt int :=  (
                    select
                        State
                    from TimeTracking
                    where Peer = 'Nickname_5'
                    order by Date, Time desc
                    limit 1
                );
begin
    if (cnt is null) then return 123;
    else return cnt;
    end if;
end;
$$ language plpgsql;

select func();
