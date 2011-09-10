
CREATE OR REPLACE FUNCTION qtypr(integer, integer) RETURNS numeric AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pLookahead ALIAS FOR $2; 

BEGIN
  RETURN qtypr(pItemsiteid, startOfTime(), (CURRENT_DATE + pLookahead));
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION qtypr(integer, date) RETURNS numeric AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pDate ALIAS FOR $2;

BEGIN
  RETURN qtypr(pItemsiteid, startOfTime(), pDate);
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION qtypr(integer, date, date) RETURNS numeric AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pStartDate ALIAS FOR $2;
  pEndDate ALIAS FOR $3;
  _prtotal NUMERIC;

BEGIN

SELECT SUM(pr_qtyreq) INTO _prtotal
  FROM pr
  WHERE ((pr_status = 'O')
    AND (pr_itemsite_id=pItemsiteid)
    AND (pr_duedate BETWEEN pStartDate AND pEndDate));

 IF (_prtotal IS NULL) THEN
     RETURN 0.0;
 END IF;

 RETURN _prtotal;

END;
$$ LANGUAGE 'plpgsql' VOLATILE;

