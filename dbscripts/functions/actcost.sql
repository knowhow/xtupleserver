CREATE OR REPLACE FUNCTION actCost(INTEGER) RETURNS NUMERIC AS '
DECLARE
  pItemid ALIAS FOR $1;
  _cost NUMERIC;

BEGIN
  RETURN actCost(pItemid, baseCurrId());
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION actCost(INTEGER, INTEGER) RETURNS NUMERIC AS '
DECLARE
  pItemid ALIAS FOR $1;
  pCurrid ALIAS FOR $2;
  _cost NUMERIC;

BEGIN

  -- Return actual cost in the given currency at the current conversion rate
  SELECT SUM(ROUND(currToCurr(itemcost_curr_id, pCurrid, itemcost_actcost, CURRENT_DATE), 6)) INTO _cost
  FROM itemcost
  WHERE (itemcost_item_id=pItemid);

  IF (_cost IS NULL) THEN
    RETURN 0;
  ELSE
    RETURN _cost;
  END IF;

END;
' LANGUAGE 'plpgsql';
