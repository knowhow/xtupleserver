CREATE OR REPLACE FUNCTION getAddrId(text) RETURNS INTEGER AS '
DECLARE
  pAddressNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pAddressNumber IS NULL OR pAddressNumber = '''') THEN
    RETURN NULL;
  END IF;

  SELECT addr_id INTO _returnVal
  FROM addr
  WHERE (addr_number=pAddressNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Address Number % not found.'', pAddressNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
