
CREATE OR REPLACE FUNCTION formatPloNumber(INTEGER) RETURNS TEXT IMMUTABLE AS '
DECLARE
  pPlanordid ALIAS FOR $1;
  _result TEXT;

BEGIN

  SELECT (TEXT(planord_number) || ''-'' || TEXT(planord_subnumber)) INTO _result
  FROM planord
  WHERE (planord_id=pPlanordid);

  RETURN _result;

END;
' LANGUAGE 'plpgsql';

