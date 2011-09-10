CREATE OR REPLACE FUNCTION postChecks(INTEGER) RETURNS INTEGER AS '
DECLARE
  pBankaccntid ALIAS FOR $1;
  _journalNumber INTEGER;

BEGIN

  SELECT fetchJournalNumber(''AP-CK'') INTO _journalNumber;

  PERFORM postCheck(checkhead_id, _journalNumber)
  FROM checkhead
  WHERE ( (NOT checkhead_void)
    AND   (NOT checkhead_posted)
    AND   (checkhead_printed)
    AND   (checkhead_bankaccnt_id=pBankaccntid) );

  RETURN _journalNumber;

END;
' LANGUAGE 'plpgsql';
