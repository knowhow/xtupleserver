CREATE OR REPLACE FUNCTION selectUninvoicedShipments(INTEGER) RETURNS INTEGER AS '
DECLARE
  pWarehousid ALIAS FOR $1;
  _r RECORD;
  _recordCounter INTEGER := 0;

BEGIN

--  Grab all of the uninvoiced coship records
  FOR _r IN SELECT DISTINCT cosmisc_id
            FROM cosmisc, coship, coitem, itemsite
            WHERE ( (coship_cosmisc_id=cosmisc_id)
             AND (coship_coitem_id=coitem_id)
             AND (coitem_itemsite_id=itemsite_id)
             AND (coitem_status <> ''C'')
             AND ( (pWarehousid = -1) OR (itemsite_warehous_id=pWarehousid) )
             AND (cosmisc_shipped)
             AND (NOT coship_invoiced)
             AND (coitem_id NOT IN ( SELECT cobill_coitem_id
                                     FROM cobmisc, cobill
                                     WHERE ((cobill_cobmisc_id=cobmisc_id)
                                      AND (NOT cobmisc_posted) ) ) ) ) LOOP

      PERFORM selectUninvoicedShipment(_r.cosmisc_id);

    _recordCounter := _recordCounter + 1;

  END LOOP;

  RETURN _recordCounter;

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION selectUninvoicedShipments(INTEGER, INTEGER) RETURNS INTEGER AS '
DECLARE
  pWarehousid ALIAS FOR $1;
  pCusttypeid ALIAS FOR $2;
  _r RECORD;
  _recordCounter INTEGER := 0;

BEGIN

--  Grab all of the uninvoiced coship records
  FOR _r IN SELECT DISTINCT cosmisc_id
            FROM cosmisc, coship, coitem, itemsite, cohead, cust
            WHERE ( (coship_cosmisc_id=cosmisc_id)
             AND (coship_coitem_id=coitem_id)
             AND (coitem_itemsite_id=itemsite_id)
             AND (coitem_status <> ''C'')
             AND (coitem_cohead_id=cohead_id)
             AND (cohead_cust_id=cust_id)
             AND (cust_custtype_id=pCusttypeid)
             AND ( (pWarehousid = -1) OR (itemsite_warehous_id=pWarehousid) )
             AND (cosmisc_shipped)
             AND (NOT coship_invoiced)
             AND (coitem_id NOT IN ( SELECT cobill_coitem_id
                                     FROM cobmisc, cobill
                                     WHERE ((cobill_cobmisc_id=cobmisc_id)
                                      AND (NOT cobmisc_posted) ) ) ) ) LOOP

      PERFORM selectUninvoicedShipment(_r.cosmisc_id);

    _recordCounter := _recordCounter + 1;

  END LOOP;

  RETURN _recordCounter;

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION selectUninvoicedShipments(INTEGER, TEXT) RETURNS INTEGER AS '
DECLARE
  pWarehousid ALIAS FOR $1;
  pCusttype ALIAS FOR $2;
  _r RECORD;
  _recordCounter INTEGER := 0;

BEGIN

--  Grab all of the uninvoiced coship records
  FOR _r IN SELECT DISTINCT cosmisc_id
            FROM cosmisc, coship, coitem, itemsite, cohead, cust, custtype
            WHERE ( (coship_cosmisc_id=cosmisc_id)
             AND (coship_coitem_id=coitem_id)
             AND (coitem_itemsite_id=itemsite_id)
             AND (coitem_status <> ''C'')
             AND (coitem_cohead_id=cohead_id)
             AND (cohead_cust_id=cust_id)
             AND (cust_custtype_id=custtype_id)
             AND ( (pWarehousid = -1) OR (itemsite_warehous_id=pWarehousid) )
             AND (custtype_code ~ pCusttype)
             AND (cosmisc_shipped)
             AND (NOT coship_invoiced)
             AND (coitem_id NOT IN ( SELECT cobill_coitem_id
                                     FROM cobmisc, cobill
                                     WHERE ((cobill_cobmisc_id=cobmisc_id)
                                      AND (NOT cobmisc_posted) ) ) ) ) LOOP

      PERFORM selectUninvoicedShipment(_r.cosmisc_id);

    _recordCounter := _recordCounter + 1;

  END LOOP;

  RETURN _recordCounter;

END;
' LANGUAGE 'plpgsql';
