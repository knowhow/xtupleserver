CREATE OR REPLACE FUNCTION formatPurchPrice(NUMERIC) RETURNS TEXT IMMUTABLE AS '
BEGIN
  RETURN formatNumeric($1, ''purchprice'');
END;' LANGUAGE 'plpgsql';
