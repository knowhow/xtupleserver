
CREATE OR REPLACE FUNCTION saveIpsProdcat(INTEGER,INTEGER,INTEGER,NUMERIC,NUMERIC,NUMERIC) RETURNS INTEGER AS '
DECLARE
  pIpsProdcatId	    ALIAS FOR $1;
  pIpsHeadId	    ALIAS FOR $2;
  pProdCatId	    ALIAS FOR $3;
  pQtyBreak	    ALIAS FOR $4;
  pDiscount	    ALIAS FOR $5;
  pFixedAmtDiscount ALIAS FOR $6;
  _ipsprodcatid	INTEGER;
  _new		BOOLEAN;
  
BEGIN

  -- Validation
  IF (SELECT COUNT(*)=0 FROM prodcat WHERE (prodcat_id=pProdcatId)) THEN
    RAISE EXCEPTION ''You must provide a valid Product Category'';
  ELSIF (COALESCE(pQtyBreak,0) < 0) THEN
    RAISE EXCEPTION ''Quantity can not be a negative value'';
  ELSIF (COALESCE(pDiscount,0) < 0) THEN
    RAISE EXCEPTION ''Discount must be a negative value'';
  END IF;
    
  _new := TRUE;

  IF (pIpsProdcatId IS NOT NULL) THEN
    SELECT ipsprodcat_id INTO _ipsprodcatid
    FROM ipsprodcat
    WHERE (ipsprodcat_id=pIpsprodcatId);

    IF (FOUND) THEN
      _new := FALSE;
    ELSE
      RAISE EXCEPTION ''Pricing Schedule Product Category not found'';
    END IF;
  ELSE
    SELECT ipsprodcat_id INTO _ipsprodcatid
    FROM ipsprodcat
    WHERE ((ipsprodcat_ipshead_id=pIpsheadId)
      AND (ipsprodcat_prodcat_id=pProdcatId)
      AND (ipsprodcat_qtybreak=pQtyBreak));

    IF (FOUND) THEN
      _new := false;
    ELSE
      _ipsprodcatid := nextval(''ipsprodcat_ipsprodcat_id_seq'');
    END IF;
  END IF;
  
  IF (_new) THEN
    INSERT INTO ipsprodcat (
      ipsprodcat_id,
      ipsprodcat_ipshead_id, 
      ipsprodcat_prodcat_id, 
      ipsprodcat_qtybreak, 
      ipsprodcat_discntprcnt,
      ipsprodcat_fixedamtdiscount)  
    VALUES (
      _ipsprodcatid,
      pIpsheadId,
      pProdcatId,
      pQtyBreak, 
      pDiscount * .01,
      pFixedAmtDiscount);
  ELSE 
    UPDATE ipsprodcat SET 
      ipsprodcat_qtybreak = pQtyBreak, 
      ipsprodcat_discntprcnt = pDiscount * .01,
      ipsprodcat_fixedamtdiscount = pFixedAmtDiscount 
    WHERE (ipsprodcat_id=_ipsprodcatid);
  END IF;

  RETURN _ipsprodcatid;
END;
' LANGUAGE 'plpgsql';

