CREATE OR REPLACE FUNCTION getIpsitemId(text,text,numeric,text,text) RETURNS INTEGER AS '
DECLARE
  pIpsName 	ALIAS FOR $1;
  pItemNumber 	ALIAS FOR $2;
  pQtyBreak	ALIAS FOR $3;
  pQtyUom	ALIAS FOR $4;
  pPriceUom	ALIAS FOR $5;
  _returnVal INTEGER;
  
BEGIN
  IF (pIpsName IS NULL AND pItemNumber IS NULL AND pQtyBreak IS NULL AND pQtyUom IS NULL AND pPriceUom IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT ipsitem_id INTO _returnVal
  FROM ipsitem
  WHERE ((ipsitem_ipshead_id=getIpsheadId(pIpsName))
  AND (ipsitem_item_id=getItemId(pItemNumber))
  AND (ipsitem_qtybreak=pQtyBreak)
  AND (ipsitem_qty_uom_id=getUomId(pQtyUom))
  AND (ipsitem_price_uom_id=getUomId(pPriceUom)));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Pricing Schedule Item for Schedule %, Item %,Qt Break %,Qty UOM %, Price UOM % not found.'', 
	pIpsName, pItemNumber, pQtyBreak, pQtyUom, pPriceUom;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
