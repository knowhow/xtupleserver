CREATE OR REPLACE FUNCTION getVendId(text) RETURNS INTEGER AS '
DECLARE
  pVendNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pVendNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT vend_id INTO _returnVal
  FROM vend
  WHERE (vend_number=pVendNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Vendor Number % not found.'', pVendNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
