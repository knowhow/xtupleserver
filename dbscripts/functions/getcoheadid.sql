CREATE OR REPLACE FUNCTION getCoheadId(text) RETURNS INTEGER AS '
DECLARE
  pSalesOrderNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pSalesOrderNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT cohead_id INTO _returnVal
  FROM cohead
  WHERE (cohead_number=pSalesOrderNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Sales Order % not found.'', pSalesOrderNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
