CREATE OR REPLACE FUNCTION formatPrice(NUMERIC) RETURNS TEXT IMMUTABLE AS $$
  SELECT formatNumeric($1, 'salesprice') AS result;
$$ LANGUAGE 'sql';
