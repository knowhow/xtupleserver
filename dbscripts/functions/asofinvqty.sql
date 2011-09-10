CREATE OR REPLACE FUNCTION asofinvqty(INTEGER, DATE) RETURNS NUMERIC STABLE AS $$
DECLARE
  pItemsiteId ALIAS FOR $1;
  pAsofDate ALIAS FOR $2;
  _result NUMERIC;

BEGIN

  SELECT invbal_qoh_ending INTO _result
  FROM asofinvbal(pItemsiteId, pAsofDate);

  RETURN COALESCE(_result, 0);
  
END;
$$ LANGUAGE 'plpgsql';
