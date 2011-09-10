CREATE OR REPLACE FUNCTION getItemSrcId(text,text) RETURNS INTEGER AS '
DECLARE
  pItemNumber ALIAS FOR $1;
  pVendNumber ALIAS FOR $2;
  _returnVal INTEGER;
BEGIN
  IF ((pItemNumber IS NULL) OR (pVendNumber IS NULL)) THEN
    RETURN NULL;
  END IF;

  SELECT itemsrc_id INTO _returnVal
  FROM itemsrc
  WHERE ((itemsrc_item_id=getItemId(pItemNumber))
  AND (itemsrc_vend_id=getVendId(pVendNumber)));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Item Source Item % Vendor % not found.'', pItemNumber,pVendNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
