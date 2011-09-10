
CREATE OR REPLACE FUNCTION isMultiCurr() RETURNS BOOL IMMUTABLE AS $$
BEGIN
  RETURN (SELECT (count(*) > 1)
          FROM curr_symbol);
END;
$$ LANGUAGE 'plpgsql';

