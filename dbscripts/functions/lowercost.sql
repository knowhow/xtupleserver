CREATE OR REPLACE FUNCTION lowerCost(INTEGER, TEXT) RETURNS NUMERIC AS $$
DECLARE
  pItemid	ALIAS FOR $1;
  pCosttype	ALIAS FOR $2;

BEGIN
    RETURN lowerCost(pItemid, pCosttype, TRUE);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION lowerCost(INTEGER, TEXT, BOOLEAN) RETURNS NUMERIC AS $$
DECLARE
  pItemid ALIAS FOR $1;
  pCosttype ALIAS FOR $2;
  pActual	ALIAS FOR $3;
  _type CHAR(1);
  _actCost	NUMERIC;
  _actCost1	NUMERIC;
  _actCost2	NUMERIC;
  _stdCost	NUMERIC;
  _stdCost1	NUMERIC;
  _stdCost2	NUMERIC;
  _cost		NUMERIC;
  _cost1	NUMERIC;
  _cost2	NUMERIC;

BEGIN

  SELECT item_type INTO _type
  FROM item
  WHERE (item_id=pItemid);

  -- find the lowercost in the base currency at the current conversion rate
  IF (_type IN ('M', 'F', 'B', 'T')) THEN
    SELECT SUM( round(currToBase(itemcost_curr_id, itemcost_actcost, CURRENT_DATE),6) * itemuomtouom(bomitem_item_id, bomitem_uom_id, NULL, (bomitem_qtyfxd/COALESCE(bomhead_batchsize,1) + bomitem_qtyper) * (1 + bomitem_scrap)) ),
           SUM( itemcost_stdcost * itemuomtouom(bomitem_item_id, bomitem_uom_id, NULL, (bomitem_qtyfxd/COALESCE(bomhead_batchsize,1) + bomitem_qtyper) * (1 + bomitem_scrap)) )
	INTO _actCost, _stdCost
    FROM bomitem(pItemid)
      JOIN item ON (item_id=bomitem_item_id AND item_type <> 'T')
      JOIN itemcost ON (itemcost_item_id=bomitem_item_id)
      JOIN costelem ON (costelem_id=itemcost_costelem_id AND costelem_type=pCosttype)
      LEFT OUTER JOIN bomhead ON ((bomhead_item_id=pItemId)
                             AND  (bomhead_rev_id=getActiveRevId('BOM',pItemId)))
    WHERE ( (bomitem_parent_item_id=pItemid)
     AND (CURRENT_DATE BETWEEN bomitem_effective AND (bomitem_expires - 1)) );

    IF (NOT FOUND) THEN
      _actCost := NULL;
      _stdCost := NULL;
    END IF;

    IF (pActual) THEN
	_cost  = _actCost;
    ELSE
	_cost  = _stdCost;
    END IF;

  ELSIF (_type IN ('C')) THEN
    SELECT SUM(CASE WHEN (bbomitem_qtyper = 0) THEN 0
                    ELSE currToBase(itemcost_curr_id, itemcost_actcost, CURRENT_DATE) / bbomitem_qtyper * bbomitem_costabsorb
               END),
	   SUM(CASE WHEN (bbomitem_qtyper = 0) THEN 0
                    ELSE itemcost_stdcost / bbomitem_qtyper * bbomitem_costabsorb
               END)
	INTO _actCost1, _stdCost1
    FROM itemcost
         JOIN costelem       ON (itemcost_costelem_id=costelem_id)
         JOIN xtmfg.bbomitem ON (bbomitem_parent_item_id=itemcost_item_id)
    WHERE ( (bbomitem_item_id=pItemid)
     AND (CURRENT_DATE BETWEEN bbomitem_effective AND (bbomitem_expires - 1))
     AND (costelem_type=pCosttype) );

    SELECT SUM(CASE WHEN (t.bbomitem_qtyper = 0) THEN 0
                    ELSE currToBase(itemcost_curr_id, itemcost_actcost, CURRENT_DATE) * s.bbomitem_qtyper / t.bbomitem_qtyper * t.bbomitem_costabsorb
               END),
	   SUM(CASE WHEN (t.bbomitem_qtyper = 0) THEN 0
                    ELSE itemcost_stdcost * s.bbomitem_qtyper / t.bbomitem_qtyper * t.bbomitem_costabsorb
               END)
	INTO _actCost2, _stdCost2
    FROM costelem
         JOIN itemcost            ON (costelem_id=itemcost_costelem_id)
         JOIN xtmfg.bbomitem AS s ON (itemcost_item_id=s.bbomitem_item_id)
         JOIN xtmfg.bbomitem AS t ON (s.bbomitem_parent_item_id=t.bbomitem_parent_item_id)
         JOIN  item               ON (s.bbomitem_item_id=item_id)
    WHERE ( (t.bbomitem_item_id=pItemid)
     AND ( CURRENT_DATE BETWEEN s.bbomitem_effective
                        AND (s.bbomitem_expires - 1) )
     AND ( CURRENT_DATE BETWEEN t.bbomitem_effective
                        AND (t.bbomitem_expires - 1) )
     AND (item_type='Y')
     AND (costelem_type=pCosttype) );

    IF (pActual) THEN
	_cost  = _actCost;
	_cost1 = _actCost1;
	_cost2 = _actCost2;
    ELSE
	_cost  = _stdCost;
	_cost1 = _stdCost1;
	_cost2 = _stdCost2;	-- should this be std or act?
    END IF;

    IF (_cost1 IS NULL AND _cost2 IS NULL) THEN
	_cost = NULL;
    ELSE
        _cost = COALESCE(_cost1, 0) + COALESCE(_cost2, 0);
    END IF;

  ELSE
    RETURN NULL;
  END IF;

  RETURN round(_cost,6);

END;
$$ LANGUAGE 'plpgsql';
