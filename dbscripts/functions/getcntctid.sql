CREATE OR REPLACE FUNCTION getCntctId(text) RETURNS INTEGER AS $$
DECLARE
  pContactNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  SELECT getCntctId(pContactNumber,true) INTO _returnVal;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION getCntctId(text,boolean) RETURNS INTEGER AS $$
DECLARE
  pContactNumber ALIAS FOR $1;
  pNotFoundErr ALIAS FOR $2;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pContactNumber), '') = '') THEN
    RETURN NULL;
  END IF;

  SELECT cntct_id INTO _returnVal
  FROM cntct
  WHERE (cntct_number=pContactNumber);

  IF (_returnVal IS NULL AND pNotFoundErr) THEN
    RAISE EXCEPTION 'Contact Number % not found.', pContactNumber;
  ELSIF (_returnVal IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';
