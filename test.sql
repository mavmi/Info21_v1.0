select
    *
from P2P
    join Checks on P2P."Check" = Checks.ID
    join Verter on Verter."Check" = Checks.ID
where
    Checks.Task = 'A1' and
    P2P.State = 'Success' and 
        (Verter.State = 'Success' or Verter.State is null);