CREATE OR REPLACE FUNCTION getPrjId(text) RETURNS INTEGER AS $$
DECLARE
  pPrjNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pPrjNumber IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT prj_id INTO _returnVal
  FROM prj
  WHERE (prj_number=pPrjNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION 'Project Number % not found.', pPrjNumber;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql' STABLE;
