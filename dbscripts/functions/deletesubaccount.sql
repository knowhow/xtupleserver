CREATE OR REPLACE FUNCTION deleteSubaccount(INTEGER) RETURNS INTEGER AS '
DECLARE
  pid ALIAS FOR $1;

BEGIN
  IF (EXISTS(SELECT accnt_id
             FROM accnt, subaccnt
             WHERE ((accnt_company=subaccnt_number)
               AND  (subaccnt_id=pid))
            )) THEN
    RETURN -1;
  END IF;

  DELETE FROM subaccnt
  WHERE (subaccnt_id=pid);

  RETURN pid;

END;
' LANGUAGE 'plpgsql';
