CREATE OR REPLACE FUNCTION summDemand(INTEGER, DATE, DATE) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pStartDate ALIAS FOR $2;
  pEndDate ALIAS FOR $3;
  _value NUMERIC;

BEGIN

  SELECT SUM(wo_qtyord - wo_qtyrcv) INTO _value
  FROM wo
  WHERE ( (wo_itemsite_id=pItemsiteid)
   AND (wo_status IN (''R'', ''I''))
   AND (wo_startdate::DATE BETWEEN pStartDate AND pEndDate) );

  IF (_value IS NULL) THEN
    _value := 0;
  END IF;

  RETURN _value;

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION summDemand(INTEGER, INTEGER) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pCalitemid ALIAS FOR $2;
  _value NUMERIC;

BEGIN

  SELECT summDemand(pItemsiteid, findPeriodStart(pCalitemid), findPeriodEnd(pCalitemid)) INTO _value;

  RETURN _value;

END;
' LANGUAGE 'plpgsql';
