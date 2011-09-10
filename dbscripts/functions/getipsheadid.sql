CREATE OR REPLACE FUNCTION getIpsheadId(text) RETURNS INTEGER AS '
DECLARE
  pIpsName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pIpsName IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT ipshead_id INTO _returnVal
  FROM ipshead
  WHERE (ipshead_name=pIpsName);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Pricing Schedule % not found.'', pIpsName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
