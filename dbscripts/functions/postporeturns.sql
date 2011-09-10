CREATE OR REPLACE FUNCTION postPoReturns(INTEGER, BOOLEAN) RETURNS INTEGER AS $$
DECLARE
  pPoheadid ALIAS FOR $1;
  pCreateMemo ALIAS FOR $2;
  _itemlocSeries INTEGER;
  _p RECORD;
  _returnval	INTEGER;

BEGIN

  _itemlocSeries := 0;

  FOR _p IN SELECT pohead_number, pohead_curr_id, poreject_id, poitem_prj_id,
		   poreject_poitem_id, poitem_id, poitem_expcat_id,
		   currToBase(pohead_curr_id, poitem_unitprice,
			      pohead_orderdate) AS poitem_unitprice_base,
                   COALESCE(itemsite_id, -1) AS itemsiteid, poitem_invvenduomratio,
                   SUM(poreject_qty) AS totalqty,
                   itemsite_item_id, itemsite_costmethod
            FROM poreject, pohead, poitem 
		LEFT OUTER JOIN itemsite ON (poitem_itemsite_id=itemsite_id)
            WHERE ( (poreject_poitem_id=poitem_id)
             AND (poitem_pohead_id=pohead_id)
             AND (pohead_id=pPoheadid)
             AND (NOT poreject_posted) )
            GROUP BY poreject_id, pohead_number, poreject_poitem_id, poitem_id,
		     poitem_expcat_id, poitem_unitprice, pohead_curr_id,
		     pohead_orderdate, itemsite_id, poitem_invvenduomratio,
                    itemsite_item_id, itemsite_costmethod, poitem_prj_id LOOP

    IF (_p.itemsiteid = -1) THEN
        SELECT insertGLTransaction( 'S/R', 'PO', _p.pohead_number, 'Return Non-Inventory to P/O',
                                     expcat_liability_accnt_id, 
                                     getPrjAccntId(_p.poitem_prj_id, expcat_exp_accnt_id), -1,
                                     round(_p.poitem_unitprice_base * _p.totalqty * -1, 2),
				     CURRENT_DATE ) INTO _returnval
        FROM expcat
        WHERE (expcat_id=_p.poitem_expcat_id);

        UPDATE poreject
        SET poreject_posted=TRUE, poreject_value= round(_p.poitem_unitprice_base * _p.totalqty, 2)
        WHERE (poreject_id=_p.poreject_id);

    ELSE
      IF (_itemlocSeries = 0) THEN
        SELECT NEXTVAL('itemloc_series_seq') INTO _itemlocSeries;
      END IF;

      SELECT postInvTrans( itemsite_id, 'RP', (_p.totalqty * _p.poitem_invvenduomratio * -1),
                           'S/R', 'PO', _p.pohead_number, '', 'Return Inventory to P/O',
                           costcat_asset_accnt_id, costcat_liability_accnt_id, _itemlocSeries, CURRENT_TIMESTAMP) INTO _returnval
      FROM itemsite, costcat
      WHERE ( (itemsite_costcat_id=costcat_id)
       AND (itemsite_id=_p.itemsiteid) );

      UPDATE poreject
      SET poreject_posted=TRUE, poreject_value=(invhist_unitcost *_p.totalqty * _p.poitem_invvenduomratio)
      FROM invhist
      WHERE ((poreject_id=_p.poreject_id)
      AND (invhist_id=_returnval));

    END IF;

    IF (_returnval < 0) THEN
      RETURN _returnval;
    END IF;


    UPDATE poitem
    SET poitem_qty_returned=(poitem_qty_returned + _p.totalqty),
	poitem_status='O'
    WHERE (poitem_id=_p.poitem_id);

    IF (pCreateMemo) THEN
	SELECT postPoReturnCreditMemo(_p.poreject_id) INTO _returnval;
    END IF;

    IF (_returnval < 0) THEN
      RETURN _returnval;
    END IF;

  END LOOP;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION postPoReturns(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pPoheadid ALIAS FOR $1;
  _itemlocSeries INTEGER;
  _p RECORD;
  _returnval	INTEGER;

BEGIN

  _itemlocSeries := 0;

  SELECT postPoReturns(pPoheadid,false) INTO _itemlocseries;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';

