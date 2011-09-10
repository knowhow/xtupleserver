
CREATE OR REPLACE FUNCTION numOfDatabaseUsers() RETURNS INTEGER AS $$
DECLARE
  _count INTEGER;

BEGIN

  SELECT count(*)
    INTO _count
    FROM pg_stat_activity, pg_locks
   WHERE((database=datid)
     AND (classid=datid)
     AND (objsubid=2)
     AND (procpid = pg_backend_pid()));
  IF (_count IS NULL) THEN
    _count := 0;
  END IF;

  RETURN _count;

END;
$$ LANGUAGE 'plpgsql';

