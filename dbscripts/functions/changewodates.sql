
CREATE OR REPLACE FUNCTION changeWoDates(INTEGER, DATE, DATE, BOOLEAN) RETURNS INTEGER AS $$
DECLARE 
  pWoid ALIAS FOR $1;
  pStartDate ALIAS FOR $2;
  pDueDate ALIAS FOR $3;
  changeChildren ALIAS FOR $4;
  _p RECORD;
  returnCode INTEGER;
  _vtemp NUMERIC;

BEGIN

  SELECT wo_status, wo_startdate, itemsite_warehous_id INTO _p
  FROM wo
  Inner Join itemsite on
      wo_itemsite_id=itemsite_id
  WHERE (wo_id=pWoid);

  IF (_p.wo_status = 'C') THEN 
    returnCode := 0;

  ELSIF (_p.wo_status IN ('R','I')) THEN
    INSERT INTO evntlog (evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                         evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number,
                         evntlog_olddate, evntlog_newdate)
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
           'W', wo_id, itemsite_warehous_id, formatWoNumber(wo_id),
           wo_duedate, pDueDate
    FROM evntnot, evnttype, itemsite, item, wo
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evntnot_warehous_id=itemsite_warehous_id)
     AND (wo_itemsite_id=itemsite_id)
     AND (itemsite_item_id=item_id)
     AND (evnttype_name='RWoDueDateRequestChange')
     AND (wo_id=pWoid) );

     returnCode := 0;

  END IF;
  
--  Reschedule operations if routings enabled
  IF ( ( SELECT (metric_value='t')
         FROM metric
         WHERE (metric_name='Routings') ) ) THEN

--    Reschedule wooper
    UPDATE xtmfg.wooper
    SET wooper_scheduled = xtmfg.calculatenextworkingdate(itemsite_warehous_id,DATE(pStartDate),
	CAST(xtmfg.calculateworkdays(itemsite_warehous_id, DATE(wo_startdate), DATE(wooper_scheduled)) as INTEGER))
    FROM wo
    Inner Join itemsite on
      wo_itemsite_id=itemsite_id
    WHERE ( (wooper_wo_id=wo_id)
     AND (wo_id=pWoid) );

--    Reschedule any womatl that is linked to wooper items
--    and is set to be scheduled with the wooper in question
    UPDATE womatl
    SET womatl_duedate=wooper_scheduled
    FROM xtmfg.wooper
    WHERE ( (womatl_schedatwooper)
     AND (womatl_wooper_id=wooper_id)
     AND (womatl_wo_id=pWoid) );
  END IF;

-- Reschedule any womatl that is not linked to wooper items
  UPDATE womatl
  SET womatl_duedate=pStartDate
  WHERE ( (NOT womatl_schedatwooper)
   AND (womatl_wo_id=pWoid) );

--  Reschedule the W/O
  UPDATE wo
  SET wo_startdate=pStartDate,
      wo_duedate=pDueDate
  WHERE (wo_id=pWoid);

--  Do the same for the children
  IF (changeChildren) THEN
    SELECT MAX(changeWoDates(wo_id, (pStartDate - itemsite_leadtime), pStartDate, TRUE)) INTO returnCode
    FROM wo, itemsite
    WHERE ( (wo_itemsite_id=itemsite_id)
     AND (wo_ordtype='W')
     AND (wo_ordid=pWoid) );
  END IF;

  IF (returnCode IS NULL) THEN
    returnCode := 0;
  END IF;

  RETURN returnCode;

END;
$$ LANGUAGE 'plpgsql';
