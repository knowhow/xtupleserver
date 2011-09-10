CREATE OR REPLACE FUNCTION deleteAPCheck(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''deleteAPCheck() is deprecated - use deleteCheck() instead'';
  RETURN deleteCheck($1);
END;
' LANGUAGE 'plpgsql';
