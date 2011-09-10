
CREATE OR REPLACE FUNCTION clearPayment(INTEGER) RETURNS INTEGER AS '
DECLARE
  pApselectid ALIAS FOR $1;

BEGIN

  DELETE FROM apselect
  WHERE (apselect_id=pApselectid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';

