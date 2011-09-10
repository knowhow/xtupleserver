CREATE OR REPLACE FUNCTION getSalesRepId(text) RETURNS INTEGER AS '
DECLARE
  pSalesRepNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pSalesRepNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT salesrep_id INTO _returnVal
  FROM salesrep
  WHERE (salesrep_number=pSalesRepNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Sales Rep Number % not found.'', pSalesRepNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
