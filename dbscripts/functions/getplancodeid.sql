CREATE OR REPLACE FUNCTION getPlanCodeId(text) RETURNS INTEGER AS '
DECLARE
  pPlanCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pPlanCode IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT plancode_id INTO _returnVal
  FROM plancode
  WHERE (plancode_code=pPlanCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Plan Code % not found.'', pPlanCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
