CREATE OR REPLACE FUNCTION createAPChecks(INTEGER, DATE) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''createAPChecks() is deprecated - use createChecks() instead'';
  RETURN createChecks($1, $2);
END;
' LANGUAGE 'plpgsql';
