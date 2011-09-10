CREATE OR REPLACE FUNCTION postMiscProduction(INTEGER, NUMERIC, BOOL, TEXT, TEXT) RETURNS INTEGER AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pBackflush ALIAS FOR $3;
  pDocNumber ALIAS FOR $4;
  pComments ALIAS FOR $5;
  _p RECORD;
  _c RECORD;
  _test INTEGER;
  _invhistid INTEGER;
  _itemlocSeries INTEGER;
  _parentQty NUMERIC;
  _qty NUMERIC;
  _laborAndOverheadCost	NUMERIC;
  _machineOverheadCost NUMERIC;
  _componentCost NUMERIC := 0;
  _itemNumber TEXT;

BEGIN

  SELECT roundQty(item_fractional, pQty) INTO _parentQty
  FROM itemsite, item
  WHERE ( (itemsite_item_id=item_id)
   AND (itemsite_id=pItemsiteid) );

--  Cache some item and itemsite parameters
  SELECT item_number, item_id,
         itemsite_loccntrl, itemsite_controlmethod,
         accnt_id AS parentWIP INTO _p
  FROM itemsite, item, costcat, accnt
  WHERE ( (itemsite_item_id=item_id)
   AND (itemsite_id=pItemsiteid)
   AND (itemsite_costcat_id=costcat_id)
   AND (costcat_wip_accnt_id=accnt_id) );
  IF (NOT FOUND) THEN
    RETURN -3;
  END IF;

--  Make sure that all Component Item Sites exist
  SELECT bomitem_id INTO _test
  FROM bomitem, itemsite
  WHERE ( (itemsite_item_id=bomitem_parent_item_id)
   AND (CURRENT_DATE BETWEEN bomitem_effective AND (bomitem_expires - 1))
   AND (itemsite_id=pItemsiteid)
   AND (bomitem_rev_id=getActiveRevId('BOM',bomitem_parent_item_id))
   AND (bomitem_item_id NOT IN
        ( SELECT component.itemsite_item_id
          FROM itemsite AS component, itemsite AS parent
          WHERE ( (pItemsiteid=parent.itemsite_id)
           AND (parent.itemsite_item_id=bomitem_parent_item_id)
           AND (bomitem_item_id=component.itemsite_item_id)
           AND (CURRENT_DATE BETWEEN bomitem_effective AND (bomitem_expires - 1))
           AND (bomitem_rev_id=getActiveRevId('BOM',bomitem_parent_item_id))
           AND (component.itemsite_active)
           AND (component.itemsite_warehous_id=parent.itemsite_warehous_id) ) ) ) )
  LIMIT 1;
  IF (FOUND AND pBackflush) THEN
    RETURN -2;
  END IF;

  SELECT NEXTVAL('itemloc_series_seq') INTO _itemlocSeries;
  SELECT postInvTrans( pItemsiteid, 'RM', _parentQty,
                       'W/O', 'WO', 'Misc.', pDocNumber,
                       ('Receive from Misc. Production for Item Number ' || _p.item_number || '
                       ' || pComments),
                       costcat_asset_accnt_id, costcat_wip_accnt_id, _itemlocSeries ) INTO _invhistid
  FROM itemsite, costcat
  WHERE ( (itemsite_costcat_id=costcat_id)
   AND (itemsite_id=pItemsiteid) );
  
  IF (pBackflush) THEN
    FOR _c IN SELECT cs.itemsite_id AS c_itemsite_id,
                     cs.itemsite_item_id AS c_item_id,
                     cs.itemsite_loccntrl AS c_itemsite_loccntrl,
                     cs.itemsite_controlmethod AS c_itemsite_controlmethod,
                     cs.itemsite_controlmethod AS c_controlmethod,
                     roundQty(itemuomfractionalbyuom(bomitem_item_id, bomitem_uom_id),
                              itemuomtouom(bomitem_item_id, bomitem_uom_id, NULL, (bomitem_qtyfxd * (1 + bomitem_scrap)) + (bomitem_qtyper * _parentQty * (1 + bomitem_scrap)))) AS qty
              FROM itemsite AS ps, itemsite AS cs, item, bomitem
              WHERE ((cs.itemsite_item_id=item_id)
               AND (ps.itemsite_item_id=bomitem_parent_item_id)
               AND (bomitem_item_id=item_id)
               AND (bomitem_rev_id=getActiveRevId('BOM',bomitem_parent_item_id))
               AND (ps.itemsite_warehous_id=cs.itemsite_warehous_id)
               AND (ps.itemsite_id=pItemsiteid)
               AND (CURRENT_DATE BETWEEN bomitem_effective AND (bomitem_expires - 1))
               AND (item_type NOT IN ('R','T')))
              ORDER BY bomitem_seqnumber LOOP
  
      _componentCost := (_componentCost + postMiscConsumption( _c.c_itemsite_id, _c.qty,
                                                       _p.item_id, _p.parentWIP, _itemlocSeries,
                                                       0, pDocNumber, pComments ) );
    END LOOP;
  END IF;

  IF (fetchMetricBool('Routings')) THEN
    _laborAndOverheadCost := (xtmfg.directLaborCost(_p.item_id) + xtmfg.overheadCost(_p.item_id)) * _parentQty;

    PERFORM insertGLTransaction('W/O', 'WO', 'Misc.',
	      ('Direct Labor And Overhead Costs of Post to Misc. Production for Item Number ' || _p.item_number),
	      costcat_laboroverhead_accnt_id, costcat_wip_accnt_id, _invhistid,
	      _laborAndOverheadCost, CURRENT_DATE)
    FROM itemsite, costcat
    WHERE ((itemsite_costcat_id=costcat_id)
      AND  (itemsite_id=pItemsiteid));

    IF fetchmetrictext('TrackMachineOverhead') = 'M' THEN
      _machineOverheadCost := xtmfg.machineoverheadCost(_p.item_id) * _parentQty;
      PERFORM insertGLTransaction('W/O', 'WO', 'Misc.',
	      ('Machine Overhead Costs of Post to Misc. Production for Item Number ' || _p.item_number),
	      costcat_laboroverhead_accnt_id, costcat_wip_accnt_id, _invhistid,
	      _machineOverheadCost, CURRENT_DATE)
      FROM itemsite, costcat
      WHERE ((itemsite_costcat_id=costcat_id)
      AND  (itemsite_id=pItemsiteid));
    ELSE
      _machineOverheadCost := 0;
    END IF;
  ELSE
    _laborAndOverheadCost := 0;
    _machineOverheadCost := 0;
  END IF;


-- Distribute to G/L - create Misc Costing Elements
  PERFORM insertGLTransaction( 'W/O', 'WO', 'Misc.',
                               ('Post Other Cost to Misc. Production for Item Number ' || _p.item_number),
                               costelem_exp_accnt_id, costcat_wip_accnt_id, _invhistid,
			       itemcost_stdcost * _parentQty,
                               CURRENT_DATE )
  FROM costelem, itemcost, costcat, itemsite
  WHERE 
    ((itemsite_id=pItemsiteid) AND
    (costelem_id = itemcost_costelem_id) AND
    (itemcost_item_id = itemsite_item_id) AND
    (itemsite_costcat_id = costcat_id) AND
    (costelem_exp_accnt_id IS NOT NULL)  AND 
    (NOT costelem_sys));



--  Distribute to G/L - create Cost Variance, debit WIP
  PERFORM insertGLTransaction( 'W/O', 'WO', 'Misc.',
                               ('Cost Variance of Post to Misc. Production for Item Number ' || _p.item_number),
                               costcat_invcost_accnt_id, costcat_wip_accnt_id, _invhistid,
			        stdcost(_p.item_id) * _parentQty - _laborAndOverheadCost - _machineOverheadCost - _componentCost - ( 
			         -- User defined cost(s)
                                SELECT COALESCE(SUM(itemcost_stdcost * _parentQty),0)
                                FROM costelem, itemcost, itemsite
                                WHERE ((itemsite_id=pItemsiteid) 
                                AND (costelem_id = itemcost_costelem_id) 
                                AND (itemcost_item_id = itemsite_item_id) 
                                AND (costelem_exp_accnt_id IS NOT NULL )
                                AND (NOT costelem_sys))),
                               CURRENT_DATE )
  FROM itemsite, costcat
  WHERE ( (itemsite_costcat_id=costcat_id)
   AND (itemsite_id=pItemsiteid) );

  RETURN _itemlocSeries;
END;
$$ LANGUAGE 'plpgsql';

