CREATE OR REPLACE FUNCTION getIpsProdcatId(text,text,numeric) RETURNS INTEGER AS '
DECLARE
  pIpsName 	ALIAS FOR $1;
  pProdCat 	ALIAS FOR $2;
  pQtyBreak	ALIAS FOR $3;
  _returnVal INTEGER;
  
BEGIN
  IF (pIpsName IS NULL AND pProdCat IS NULL AND pQtyBreak IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT ipsprodcat_id INTO _returnVal
  FROM ipsprodcat
  WHERE ((ipsprodcat_ipshead_id=getIpsheadId(pIpsName))
  AND (ipsprodcat_prodcat_id=getProdcatId(pProdCat))
  AND (ipsprodcat_qtybreak=pQtyBreak));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Pricing Schedule Product Category for Schedule %, Product Category %,Qt Break % not found.'', 
	pIpsName, pProdCat, pQtyBreak;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
