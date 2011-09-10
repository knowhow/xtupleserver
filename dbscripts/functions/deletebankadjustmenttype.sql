
CREATE OR REPLACE FUNCTION deleteBankAdjustmentType(INTEGER) RETURNS INTEGER AS '
DECLARE
  pBankadjtypeid ALIAS FOR $1;
  _check INTEGER;

BEGIN

-- Check to see if the the adjustment type is being used in any adjustments
  SELECT bankadj_bankadjtype_id INTO _check
    FROM bankadj
   WHERE (bankadj_bankadjtype_id=pBankadjtypeid)
   LIMIT 1;
  IF (FOUND) THEN
    RETURN -1;
  END IF;

--  Delete the Account
  DELETE FROM bankadjtype
  WHERE (bankadjtype_id=pbankadjtypeid);

  RETURN 0;

END;
' LANGUAGE 'plpgsql';

