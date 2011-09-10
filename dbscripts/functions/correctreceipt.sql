CREATE OR REPLACE FUNCTION correctReceipt(INTEGER, NUMERIC, NUMERIC, INTEGER, INTEGER, DATE) RETURNS INTEGER AS $$
DECLARE
  precvid		ALIAS FOR $1;
  pQty			ALIAS FOR $2;
  pFreight		ALIAS FOR $3;
  _itemlocSeries	INTEGER := $4;
  _currid		INTEGER := $5;
  pEffective		ALIAS FOR $6;
  _freight		NUMERIC;
  _qty			NUMERIC;
  _invhistid		INTEGER;
  _o			RECORD;
  _r			RECORD;

BEGIN
  SELECT recv_qty, recv_date::DATE AS recv_date, recv_freight_curr_id,
	 recv_orderitem_id,
	 round(currToCurr(recv_freight_curr_id,
			  COALESCE(_currid, recv_freight_curr_id),
         recv_freight, recv_date::DATE),2) AS recv_freight,
         recv_posted, recv_order_type,
         COALESCE(itemsite_id, -1) AS itemsiteid,
	 itemsite_item_id, itemsite_costmethod,
	 (recv_splitfrom_id IS NOT NULL
	 OR (SELECT (count(*) > 0) 
	     FROM recv
	     WHERE (recv_splitfrom_id=recv_id))) AS split INTO _r
  FROM recv LEFT OUTER JOIN itemsite ON (recv_itemsite_id=itemsite_id)
  WHERE (recv_id=precvid);

  IF (NOT FOUND) THEN
    RETURN _itemlocSeries;
  END IF;

  IF (NOT _r.recv_order_type IN ('PO', 'RA', 'TO')) THEN
    RETURN -11;
  END IF;

  IF (_r.split) THEN
    RETURN -12;
  END IF;

  SELECT currToBase(orderitem_unitcost_curr_id, orderitem_unitcost,
		    _r.recv_date::DATE) AS unitprice_base,
	 orderhead_number, orderitem_linenumber,
	 orderhead_curr_id AS freight_curr_id,
	 orderitem_orderhead_type,
	 orderitem_qty_invuomratio INTO _o
  FROM orderhead, orderitem
  WHERE ((orderhead_id=orderitem_orderhead_id)
    AND  (orderhead_type=orderitem_orderhead_type)
    AND  (orderitem_id=_r.recv_orderitem_id)
    AND  (orderitem_orderhead_type=_r.recv_order_type));

  IF (NOT FOUND) THEN
    RETURN _itemlocSeries;
  END IF;

  IF (_r.recv_posted) THEN
    _qty := (pQty - _r.recv_qty);
    IF (_qty <> 0) THEN
      IF (_r.itemsiteid = -1) THEN
	PERFORM insertGLTransaction( 'S/R', _r.recv_order_type,
				      _o.orderhead_number,
				      'Receive Non-Inventory from ' ||
							    _r.recv_order_type,
				      expcat_liability_accnt_id,
				      getPrjAccntId(poitem_prj_id, expcat_exp_accnt_id), -1,
				      ROUND(_o.unitprice_base * _qty, 2),
				      pEffective )
	FROM poitem, expcat
	WHERE ((poitem_expcat_id=expcat_id)
	  AND  (poitem_id=_r.recv_orderitem_id)
	  AND  (_o.orderitem_orderhead_type='PO'));

	UPDATE recv
	SET recv_qty=pQty,
	    recv_value=(recv_value + ROUND(_o.unitprice_base * _qty, 2)),
            recv_date = pEffective
	WHERE (recv_id=precvid);

      ELSE
	IF (_itemlocSeries = 0 OR _itemlocSeries IS NULL) THEN
	  _itemlocSeries := NEXTVAL('itemloc_series_seq');
	END IF;

	SELECT postInvTrans( itemsite_id, 'RP',
			     (_qty * _o.orderitem_qty_invuomratio),
			     'S/R', _r.recv_order_type,
			     _o.orderhead_number::TEXT || '-' || _o.orderitem_linenumber::TEXT, '',
			     'Receive Inventory from ' || _r.recv_order_type,
			     costcat_asset_accnt_id,
			     costcat_liability_accnt_id,
			     _itemlocSeries, pEffective,
                             ROUND(_o.unitprice_base * _qty, 2) -- alway passing since it is ignored if not average costed item
                           ) INTO _invhistid
	FROM itemsite, costcat
	WHERE ((itemsite_costcat_id=costcat_id)
	  AND  (itemsite_id=_r.itemsiteid) );

        IF(_r.itemsite_costmethod='A') THEN
	  UPDATE recv
	     SET recv_qty=pQty,
	         recv_value=(recv_value + _o.unitprice_base * _qty * _o.orderitem_qty_invuomratio),
                 recv_date = pEffective
	   WHERE(recv_id=precvid);
        ELSE
	  UPDATE recv
	     SET recv_qty=pQty,
	         recv_value=(recv_value + stdcost(_r.itemsite_item_id) * _qty * _o.orderitem_qty_invuomratio),
                 recv_date = pEffective
	   WHERE(recv_id=precvid);
        END IF;

      END IF;

      IF (_r.recv_order_type = 'PO') THEN
	UPDATE poitem
	SET poitem_qty_received=(poitem_qty_received + _qty)
	WHERE (poitem_id=_r.recv_orderitem_id);
      ELSIF (_r.recv_order_type = 'RA' AND fetchMetricBool('EnableReturnAuth')) THEN
	UPDATE raitem
	SET raitem_qtyreceived=(raitem_qtyreceived + _qty)
	WHERE (raitem_id=_r.recv_orderitem_id);
      ELSIF (_r.recv_order_type = 'TO' AND fetchMetricBool('MultiWhs')) THEN
	UPDATE toitem
	SET toitem_qty_received=(toitem_qty_received + _qty)
	WHERE (toitem_id=_r.recv_orderitem_id);
      END IF;

    END IF;

    _freight := (pFreight - _r.recv_freight);
    IF (_freight <> 0) THEN

      IF (_r.itemsiteid = -1) THEN
	PERFORM insertGLTransaction( 'S/R', _r.recv_order_type,
				     _o.orderhead_number,
				    'Receive Non-Inventory Freight from ' || _r.recv_order_type,
				     expcat_liability_accnt_id, getPrjAccntId(poitem_prj_id, expcat_freight_accnt_id), -1,
				      ROUND(currToBase(_currid, _freight,
						    pEffective), 2),
				     pEffective )
	FROM poitem, expcat
	WHERE ((poitem_expcat_id=expcat_id)
	  AND  (poitem_id=_r.recv_orderitem_id)
	  AND  (_r.recv_order_type='PO'));
      ELSE
	PERFORM insertGLTransaction('S/R', _r.recv_order_type,
				    _o.orderhead_number, 
				    'Receive Non-Inventory Freight from ' ||
							    _r.recv_order_type,
				   costcat_liability_accnt_id,
				   costcat_freight_accnt_id, -1,
				   round(currToBase(_currid, _freight,
						    pEffective), 2),
				   pEffective )
	FROM itemsite, costcat
	WHERE ( (itemsite_costcat_id=costcat_id)
	  AND   (itemsite_id=_r.itemsiteid) );
      END IF;

      IF (_r.recv_order_type = 'PO') THEN
	UPDATE poitem
	SET poitem_freight_received=(poitem_freight_received +
				   currToCurr(_currid, _o.freight_curr_id,
					      _freight, pEffective))
	WHERE (poitem_id=_r.recv_orderitem_id);

      -- raitem does not track freight

      ELSEIF (_r.recv_order_type = 'TO' AND fetchMetricBool('MultiWhs')) THEN
	UPDATE toitem
	SET toitem_freight_received=(toitem_freight_received +
				   currToCurr(_currid, _o.freight_curr_id,
					      _freight, pEffective))
	WHERE (toitem_id=_r.recv_orderitem_id);
      END IF;

      UPDATE recv
      SET recv_freight=currToCurr(_currid, recv_freight_curr_id, pFreight,
				  pEffective),
	  recv_date = pEffective
      WHERE (recv_id=precvid);
    END IF;

  ELSE

-- Receipt not posted yet
    UPDATE recv SET recv_qty=pQty, recv_freight=pFreight WHERE recv_id=precvid;
  END IF;

RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';
