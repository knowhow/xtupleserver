CREATE OR REPLACE FUNCTION getCostElemId(text) RETURNS INTEGER AS '
DECLARE
  pCostElemType ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pCostElemType IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT costelem_id INTO _returnVal
  FROM costelem
  WHERE (costelem_type=pCostElemType);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Cost Element % not found.'', pCostElemType;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
