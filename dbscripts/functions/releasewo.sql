CREATE OR REPLACE FUNCTION releaseWo(INTEGER, BOOLEAN) RETURNS INTEGER AS '
DECLARE
  pWoid ALIAS FOR $1;
  releaseChildren ALIAS FOR $2;
  returnCode INTEGER;
BEGIN
  UPDATE wo
  SET wo_status=''R''
  WHERE ((wo_status=''E'')
   AND (wo_id=pWoid));

  IF (releaseChildren) THEN
    returnCode := (SELECT MAX(releaseWo(wo_id, TRUE))
                   FROM wo
                   WHERE ((wo_ordtype=''W'')
                    AND (wo_ordid=pWoid)));
  END IF;

  RETURN 0;
END;
' LANGUAGE 'plpgsql';