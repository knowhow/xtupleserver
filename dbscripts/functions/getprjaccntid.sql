CREATE OR REPLACE FUNCTION getPrjAccntId(INTEGER, INTEGER) RETURNS INTEGER IMMUTABLE AS $$
DECLARE
  pPrjid ALIAS FOR $1;
  pAccntid ALIAS FOR $2;
  
BEGIN
  -- Project Accounting is required to fully implement this functionality
  RETURN pAccntId;
END;
$$ LANGUAGE 'plpgsql';
