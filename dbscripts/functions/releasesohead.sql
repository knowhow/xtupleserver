
CREATE OR REPLACE FUNCTION releaseSohead(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pSoheadid ALIAS FOR $1;

BEGIN

  DELETE FROM soheadlock
   WHERE ( (soheadlock_sohead_id=pSoheadid)
     AND   (soheadlock_username=getEffectiveXtUser())
     AND   (soheadlock_procpid=pg_backend_pid()) );

  RETURN TRUE;
END;
' LANGUAGE 'plpgsql';

