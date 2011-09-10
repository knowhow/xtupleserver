CREATE OR REPLACE FUNCTION getSalesCatId(text) RETURNS INTEGER AS '
DECLARE
  pSalesCatName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pSalesCatName IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT salescat_id INTO _returnVal
  FROM salescat
  WHERE (salescat_name=pSalesCatName);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Sales Category % not found.'', pSalesCatName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
