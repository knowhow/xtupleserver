CREATE OR REPLACE FUNCTION summTransA (INTEGER, DATE, DATE) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pStartDate ALIAS FOR $2;
  pEndDate ALIAS FOR $3;
  _value NUMERIC;

BEGIN

  SELECT SUM(invhist_invqty) INTO _value
  FROM invhist
  WHERE ((invhist_transdate::DATE BETWEEN pStartDate AND pEndDate)
   AND (invhist_transtype IN (''AD'', ''CC''))
   AND (invhist_itemsite_id=pItemsiteid));

  IF (_value IS NULL) THEN
    _value := 0;
  END IF;

  RETURN _value;

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION summTransA(INTEGER, INTEGER) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pCalitemid ALIAS FOR $2;
  _value NUMERIC;

BEGIN

  SELECT summTransA(pItemsiteid, findPeriodStart(pCalitemid), findPeriodEnd(pCalitemid)) INTO _value;

  RETURN _value;

END;
' LANGUAGE 'plpgsql';
