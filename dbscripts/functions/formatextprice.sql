CREATE OR REPLACE FUNCTION formatExtPrice(NUMERIC) RETURNS TEXT IMMUTABLE AS '
BEGIN
  RETURN formatNumeric($1, ''extprice'');
END;'
LANGUAGE 'plpgsql';