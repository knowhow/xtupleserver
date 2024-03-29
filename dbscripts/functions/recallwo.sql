CREATE OR REPLACE FUNCTION recallWo(INTEGER, BOOLEAN) RETURNS INTEGER AS '
DECLARE
  pWoid ALIAS FOR $1;
  recallChildren ALIAS FOR $2;
  returnCode INTEGER;

BEGIN

  UPDATE wo
  SET wo_status=''E''
  WHERE ((wo_status=''R'')
   AND (wo_id=pWoid));

  IF (recallChildren) THEN
    returnCode := (SELECT MAX(recallWo(wo_id, TRUE))
                   FROM wo
                   WHERE ((wo_ordtype=''W'')
                    AND (wo_ordid=pWoid)));
  END IF;

  RETURN 0;
END;
' LANGUAGE 'plpgsql';