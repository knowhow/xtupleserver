CREATE OR REPLACE FUNCTION postAPCheck(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''postAPCheck() is deprecated - use postCheck() instead'';
  RETURN postCheck($1, fetchJournalNumber(''AP-CK''));
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION postAPCheck(INTEGER, INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''postAPCheck() is deprecated - use postCheck() instead'';
  RETURN postCheck($1, $2);
END;
' LANGUAGE 'plpgsql';
