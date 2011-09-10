CREATE OR REPLACE FUNCTION getVendAddrId(text, text) RETURNS INTEGER AS '
DECLARE
  pVendNumber   ALIAS FOR $1;
  pVendAddrCode ALIAS FOR $2;
  _returnVal INTEGER;
BEGIN
  IF ( (pVendNumber IS NULL) OR (pVendAddrCode IS NULL) ) THEN
    RETURN NULL;
  END IF;

  SELECT vendaddr_id INTO _returnVal
  FROM vendaddr, vendinfo
  WHERE ( (vendaddr_code=pVendAddrCode)
    AND   (vend_id=vendaddr_vend_id)
    AND   (vend_number=pVendNumber) );

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Vendor Number % Address % not found.'', pVendNumber, pVendAddrCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
