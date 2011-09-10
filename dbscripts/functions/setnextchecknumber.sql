
CREATE OR REPLACE FUNCTION setNextCheckNumber(INTEGER, INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pBankaccntid ALIAS FOR $1;
  pNextCheckNumber ALIAS FOR $2;

BEGIN

  UPDATE bankaccnt
  SET bankaccnt_nextchknum=pNextCheckNumber
  WHERE (bankaccnt_id=pBankaccntid);

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

