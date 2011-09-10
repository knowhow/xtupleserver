CREATE OR REPLACE FUNCTION postSoItemProduction(INTEGER, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
DECLARE
  pSoitemId      ALIAS FOR $1;
  pGlDistTS      ALIAS FOR $2;
  _qty NUMERIC;
  
BEGIN
  -- Issuing all, so determine line balance
  SELECT noNeg( coitem_qtyord - coitem_qtyshipped + coitem_qtyreturned - 
              ( SELECT COALESCE(SUM(shipitem_qty), 0)
                FROM shipitem, shiphead
                WHERE ((shipitem_orderitem_id=coitem_id)
                  AND  (shipitem_shiphead_id=shiphead_id)
                  AND  (NOT shiphead_shipped) ) ) ) INTO _qty
  FROM coitem
  WHERE (coitem_id=pSoitemId);

  RETURN postSoItemProduction($1, _qty, $2);
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION postSoItemProduction(INTEGER, NUMERIC, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
DECLARE
  pSoitemId ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pGlDistTS ALIAS FOR $3;
  _itemlocSeries INTEGER := 0;
  
BEGIN
  --If this cost method is not Job then we are using the wrong function
  IF (NOT EXISTS(SELECT itemsite_costmethod
             FROM coitem,itemsite
             WHERE ((coitem_id=pSoitemId)
                AND (coitem_itemsite_id=itemsite_id)
                AND (itemsite_costmethod = 'J')))) THEN
    RAISE EXCEPTION 'The postSoLineBalanceProduction function may only be used with Job costed item sites';
  END IF;

  IF (pQty > 0) THEN
    SELECT COALESCE(postProduction(wo_id, pQty, true, 0, pGlDistTS),-1) INTO _itemlocSeries
    FROM wo
    WHERE ((wo_ordid=pSoItemid)
     AND (wo_ordtype='S'));
    
    UPDATE wo SET wo_status = 'C'
    WHERE ((wo_ordid=pSoItemid)
     AND (wo_ordtype='S')
     AND (wo_qtyrcv >= wo_qtyord));
  END IF;

  RETURN _itemlocSeries;
END;
$$ LANGUAGE 'plpgsql';

