CREATE OR REPLACE FUNCTION postVouchers(BOOLEAN) RETURNS INTEGER AS $$
DECLARE
  pPostCosts ALIAS FOR $1;
  _journalNumber INTEGER;

BEGIN

  SELECT fetchJournalNumber('AP-VO') INTO _journalNumber;

  PERFORM postVoucher(vohead_id, _journalNumber, pPostCosts)
  FROM vohead
  WHERE (NOT vohead_posted);

  RETURN _journalNumber;

END;
$$ LANGUAGE 'plpgsql';
