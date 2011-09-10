CREATE OR REPLACE FUNCTION voidPostedAPCheck(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''voidPostedAPCheck() is deprecated - use voidPostedCheck() instead'';
  RETURN voidPostedCheck($1, fetchJournalNumber(''AP-CK''), CURRENT_DATE);
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION voidPostedAPCheck(INTEGER, INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''voidPostedAPCheck() is deprecated - use voidPostedCheck() instead'';
  RETURN voidPostedCheck($1, $2, CURRENT_DATE);
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION voidPostedAPCheck(INTEGER, INTEGER, DATE) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''voidPostedAPCheck() is deprecated - use voidPostedCheck() instead'';
  RETURN voidPostedCheck($1, $2, $3);
END;
' LANGUAGE 'plpgsql';
