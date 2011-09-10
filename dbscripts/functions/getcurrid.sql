CREATE OR REPLACE FUNCTION getCurrId(text) RETURNS INTEGER AS '
DECLARE
  pCurrName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pCurrName IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT curr_id INTO _returnVal
  FROM curr_symbol
  WHERE (curr_abbr=pCurrName);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Currency % not found.'', pCurrName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
