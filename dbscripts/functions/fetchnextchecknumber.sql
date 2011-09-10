
CREATE OR REPLACE FUNCTION fetchNextCheckNumber(INTEGER) RETURNS INTEGER AS '
DECLARE
  pBankaccntid ALIAS FOR $1;
  _nextChkNumber INTEGER;

BEGIN

  SELECT bankaccnt_nextchknum INTO _nextChkNumber
  FROM bankaccnt
  WHERE (bankaccnt_id=pBankaccntid);

  UPDATE bankaccnt
  SET bankaccnt_nextchknum = (bankaccnt_nextchknum + 1)
  WHERE (bankaccnt_id=pBankaccntid);

  RETURN _nextChkNumber;

END;
' LANGUAGE 'plpgsql';

