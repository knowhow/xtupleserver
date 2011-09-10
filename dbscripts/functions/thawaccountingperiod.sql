
CREATE OR REPLACE FUNCTION thawAccountingPeriod(INTEGER) RETURNS INTEGER AS '
DECLARE
  pPeriodid ALIAS FOR $1;
  _r RECORD;

BEGIN

--  Check to make use that the period is frozen
  IF ( ( SELECT (NOT period_freeze)
         FROM period
         WHERE (period_id=pPeriodid) ) ) THEN
    RETURN -2;
  END IF;

--  Reset the period_freeze flag
  UPDATE period
  SET period_freeze=FALSE
  WHERE (period_id=pPeriodid);

--  Post any unposted G/L Transactions into the period
  FOR _r IN SELECT DISTINCT gltrans_sequence
            FROM gltrans, accnt, period
            WHERE ( (gltrans_accnt_id=accnt_id)
             AND (NOT gltrans_posted)
             AND (accnt_closedpost)
             AND (gltrans_date BETWEEN period_start AND period_end)
             AND (period_id=pPeriodid) ) LOOP
    PERFORM postIntoTrialBalance(_r.gltrans_sequence);
  END LOOP;

  RETURN pPeriodid;

END;
' LANGUAGE 'plpgsql';

