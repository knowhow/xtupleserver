CREATE OR REPLACE FUNCTION getSoSchedDate(INTEGER) RETURNS DATE AS $$
DECLARE
  pCoheadid ALIAS FOR $1;
  _minscheddate DATE;

BEGIN

  SELECT MIN(coitem_scheddate) INTO _minscheddate
  FROM coitem
  WHERE ( (coitem_cohead_id=pCoheadid)
    AND   (coitem_status <> 'X') );

  RETURN _minscheddate;

END;
$$ LANGUAGE 'plpgsql';
