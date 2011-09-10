CREATE OR REPLACE FUNCTION getItemId(text) RETURNS INTEGER IMMUTABLE AS '
DECLARE
  pItemNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pItemNumber IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT item_id INTO _returnVal
  FROM item
  WHERE (item_number=UPPER(pItemNumber));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Item % not found.'', pItemNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
