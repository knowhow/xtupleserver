CREATE OR REPLACE FUNCTION formatSalesPrice(NUMERIC) RETURNS TEXT IMMUTABLE AS '
BEGIN
  RETURN formatNumeric($1, ''salesprice'');
END;' LANGUAGE 'plpgsql';
