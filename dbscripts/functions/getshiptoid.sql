CREATE OR REPLACE FUNCTION getShiptoId(text, text) RETURNS INTEGER AS '
DECLARE
  pCustNumber ALIAS FOR $1;
  pShiptoNumber ALIAS FOR $2;
  _returnVal INTEGER;
BEGIN
  IF ((pCustNumber IS NULL) OR (pShiptoNumber IS NULL)) THEN
	RETURN NULL;
  END IF;

  SELECT shipto_id INTO _returnVal
  FROM shiptoinfo
  WHERE ((shipto_cust_id=getCustId(pCustNumber,true))
  AND (UPPER(shipto_num)=UPPER(pShiptoNumber)));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Shipto % not found.'', pShiptoNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
