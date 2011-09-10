CREATE OR REPLACE FUNCTION deleteProfitCenter(INTEGER) RETURNS INTEGER AS '
DECLARE
  pid ALIAS FOR $1;

BEGIN
  IF (EXISTS(SELECT accnt_id
             FROM accnt, prftcntr
             WHERE ((accnt_company=prftcntr_number)
               AND  (prftcntr_id=pid))
            )) THEN
    RETURN -1;
  END IF;

  DELETE FROM prftcntr
  WHERE (prftcntr_id=pid);

  RETURN pid;

END;
' LANGUAGE 'plpgsql';
