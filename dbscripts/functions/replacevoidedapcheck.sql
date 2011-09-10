CREATE OR REPLACE FUNCTION replaceVoidedAPCheck(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''replaceVoidedAPCheck() is deprecated - use replaceVoidedCheck()'';
  RETURN replaceVoidedCheck($1);
END;
' LANGUAGE 'plpgsql';
