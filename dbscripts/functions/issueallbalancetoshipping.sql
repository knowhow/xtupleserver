CREATE OR REPLACE FUNCTION issueAllBalanceToShipping(INTEGER) RETURNS INTEGER AS $$
BEGIN
  RETURN issueAllBalanceToShipping('SO', $1, 0, NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION issueAllBalanceToShipping(TEXT, INTEGER, INTEGER, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
DECLARE
  pordertype		ALIAS FOR $1;
  pheadid		ALIAS FOR $2;
  _itemlocSeries	INTEGER 		 := $3;
  _timestamp		TIMESTAMP WITH TIME ZONE := $4;
  _s			RECORD;

BEGIN
  IF (pordertype = 'SO') THEN
    FOR _s IN SELECT coitem_id,
		     noNeg(coitem_qtyord - coitem_qtyshipped + coitem_qtyreturned -
			   ( SELECT COALESCE(SUM(shipitem_qty), 0)
			     FROM shipitem, shiphead
			     WHERE ( (shipitem_orderitem_id=coitem_id)
			      AND (shipitem_shiphead_id=shiphead_id)
			      AND (NOT shiphead_shipped)
			      AND (shiphead_order_type=pordertype) ) ) ) AS balance
	      FROM coitem LEFT OUTER JOIN (itemsite JOIN item ON (itemsite_item_id=item_id)) ON (coitem_itemsite_id=itemsite_id)
	      WHERE ( (coitem_status NOT IN ('C','X'))
                AND (item_type != 'K')
	       AND (coitem_cohead_id=pheadid) ) LOOP

      IF (_s.balance <> 0) THEN
	_itemlocSeries := issueToShipping(pordertype, _s.coitem_id, _s.balance, _itemlocSeries, _timestamp);
	IF (_itemlocSeries < 0) THEN
	  EXIT;
	END IF;
      END IF;
    END LOOP;

  ELSEIF (pordertype = 'TO') THEN
    FOR _s IN SELECT toitem_id,
		     noNeg( toitem_qty_ordered - toitem_qty_shipped -
			   ( SELECT COALESCE(SUM(shipitem_qty), 0)
			     FROM shipitem, shiphead
			     WHERE ( (shipitem_orderitem_id=toitem_id)
			      AND (shipitem_shiphead_id=shiphead_id)
			      AND (NOT shiphead_shipped)
			      AND (shiphead_order_type=pordertype) ) ) ) AS balance
	      FROM toitem
	      WHERE ( (toitem_status NOT IN ('C','X'))
	       AND (toitem_tohead_id=pheadid) ) LOOP

      IF (_s.balance <> 0) THEN
	_itemlocSeries := issueToShipping(pordertype, _s.toitem_id, _s.balance, _itemlocSeries, _timestamp);
	IF (_itemlocSeries < 0) THEN
	  EXIT;
	END IF;
      END IF;
    END LOOP;

  ELSE
    RETURN -1;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';
