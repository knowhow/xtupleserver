CREATE OR REPLACE FUNCTION getPoheadId(text) RETURNS INTEGER AS '
DECLARE
  pPurchaseOrderNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pPurchaseOrderNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT pohead_id INTO _returnVal
  FROM pohead
  WHERE (pohead_number=pPurchaseOrderNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Purchase Order % not found.'', pPurchaseOrderNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
