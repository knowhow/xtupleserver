CREATE OR REPLACE FUNCTION markAPCheckASPosted(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''markAPCheckAsPosted() is deprecated - use markCheckAsPosted() instead'';
  RETURN markCheckAsPosted($1);

END;
' LANGUAGE 'plpgsql';
