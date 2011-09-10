CREATE OR REPLACE FUNCTION invExpense(INTEGER, NUMERIC, INTEGER, TEXT, TEXT) RETURNS INTEGER AS $$
BEGIN
 RETURN invExpense($1, $2, $3, $4, $5, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION invExpense(INTEGER, NUMERIC, INTEGER, TEXT, TEXT, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
BEGIN
 RETURN invExpense($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION invExpense(INTEGER, NUMERIC, INTEGER, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pExpcatid ALIAS FOR $3;
  pDocumentNumber ALIAS FOR $4;
  pComments ALIAS FOR $5;
  pGlDistTS ALIAS FOR $6;
  pPrjid ALIAS FOR $7;
  _invhistid INTEGER;
  _itemlocSeries INTEGER;

BEGIN

--  Make sure the passed itemsite points to a real item
  IF ( ( SELECT (item_type IN ('R', 'F') OR itemsite_costmethod = 'J')
         FROM itemsite, item
         WHERE ( (itemsite_item_id=item_id)
          AND (itemsite_id=pItemsiteid) ) ) ) THEN
    RETURN 0;
  END IF;

  SELECT NEXTVAL('itemloc_series_seq') INTO _itemlocSeries;
  SELECT postInvTrans( itemsite_id, 'EX', pQty,
                       'I/M', 'EX', pDocumentNumber, '',
                       CASE WHEN (pQty < 0) THEN ('Reverse Material Expense for item ' || item_number || E'\n' ||  pComments)
                            ELSE  ('Material Expense for item ' || item_number || E'\n' ||  pComments)
                       END,
                       getPrjAccntId(pPrjid, expcat_exp_accnt_id), costcat_asset_accnt_id,
                       _itemlocSeries, pGlDistTS) INTO _invhistid
  FROM itemsite, item, costcat, expcat
  WHERE ( (itemsite_item_id=item_id)
   AND (itemsite_costcat_id=costcat_id)
   AND (itemsite_id=pItemsiteid)
   AND (expcat_id=pExpcatid) );

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';
