CREATE OR REPLACE FUNCTION postAPChecks(INTEGER) RETURNS INTEGER AS '
BEGIN

  RAISE NOTICE ''postAPChecks() is deprecated - use postChecks() instead'';
  RETURN postChecks($1);

END;
' LANGUAGE 'plpgsql';
