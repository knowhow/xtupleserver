CREATE OR REPLACE FUNCTION getIncidentId(integer) RETURNS INTEGER AS '
DECLARE
  pIncidentNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pIncidentNumber IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT incdt_id INTO _returnVal
  FROM incdt
  WHERE (incdt_number=pIncidentNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Incident Number % not found.'', pIncidentNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
