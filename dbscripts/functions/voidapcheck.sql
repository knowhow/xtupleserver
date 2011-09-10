CREATE OR REPLACE FUNCTION voidAPCheck(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''voidAPCheck() is deprecated - use voidCheck() instead'';
  RETURN voidCheck($1);
END;
' LANGUAGE 'plpgsql';
