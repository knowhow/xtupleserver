
CREATE OR REPLACE FUNCTION freezeAccountingPeriod(INTEGER) RETURNS INTEGER AS '
DECLARE
  pPeriodid ALIAS FOR $1;

BEGIN

--  Check to make use that the period is closed
  IF ( ( SELECT (NOT period_closed)
         FROM period
         WHERE (period_id=pPeriodid) ) ) THEN
    RETURN -1;
  END IF;

--  Check to make use that the period is not already frozen
  IF ( ( SELECT period_freeze
         FROM period
         WHERE (period_id=pPeriodid) ) ) THEN
    RETURN -2;
  END IF;

--  Set the period_freeze flag
  UPDATE period
  SET period_freeze=TRUE
  WHERE (period_id=pPeriodid);

  RETURN pPeriodid;

END;
' LANGUAGE 'plpgsql';

