CREATE OR REPLACE FUNCTION getFreightClassId(text) RETURNS INTEGER AS '
DECLARE
  pFreightClassCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pFreightClassCode IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT freightclass_id INTO _returnVal
  FROM freightclass
  WHERE (freightclass_code=pFreightClassCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Freight Class % not found.'', pFreightClassCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
