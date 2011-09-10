CREATE OR REPLACE FUNCTION createMiscAPCheck(INTEGER, INTEGER, DATE, NUMERIC, INTEGER, TEXT, TEXT) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''createMiscAPCheck() is deprecated - use createCheck() instead'';
  RETURN createCheck($1, ''V'', $2, $3, $4, baseCurrId(), $5, NULL, $6, $7, FALSE);
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION createMiscAPCheck(INTEGER, INTEGER, DATE, NUMERIC, INTEGER, INTEGER, TEXT, TEXT) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''createMiscAPCheck() is deprecated - use createCheck() instead'';
  RETURN createCheck($1, ''V'', $2, $3, pAmount, $5, $6, NULL, $7, $8, FALSE);
END;
' LANGUAGE 'plpgsql';
