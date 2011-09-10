CREATE OR REPLACE FUNCTION replaceAllVoidedAPChecks(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''replaceAllVoidedAPChecks() is deprecated - use replaceAllVoidedChecks() instead'';
  RETURN replaceAllVoidedChecks($1);
END;
' LANGUAGE 'plpgsql';
