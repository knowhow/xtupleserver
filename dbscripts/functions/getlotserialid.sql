CREATE OR REPLACE FUNCTION getLotSerialId(text, text) RETURNS INTEGER AS '
DECLARE
  pItemNumber ALIAS FOR $1;
  pLotSerialNumber ALIAS FOR $2;
  _returnVal INTEGER;
BEGIN
  IF ((pItemNumber IS NULL) OR (pLotSerialNumber IS NULL) OR (pLotSerialNumber='''')) THEN
	RETURN NULL;
  END IF;

  SELECT ls_id INTO _returnVal
  FROM ls
  WHERE ((ls_item_id=getItemId(pItemNumber))
  AND (UPPER(ls_number)=UPPER(pLotSerialNumber)));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''LotSerial % not found.'', pLotSerialNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
