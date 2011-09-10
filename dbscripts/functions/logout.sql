
CREATE OR REPLACE FUNCTION logout() RETURNS integer AS $$
BEGIN
  PERFORM pg_advisory_unlock(datid::integer, procpid)
     FROM pg_stat_activity
    WHERE(procpid = pg_backend_pid());

  RETURN 0;
END;
$$ LANGUAGE 'plpgsql';


