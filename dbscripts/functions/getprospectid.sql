CREATE OR REPLACE FUNCTION getProspectId(TEXT) RETURNS INTEGER AS $$
DECLARE
  pProspectNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pProspectNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT prospect_id INTO _returnVal
    FROM prospect
   WHERE(UPPER(prospect_number)=UPPER(pProspectNumber));
  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION 'Prospect Number % found.', pProspectNumber;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';
