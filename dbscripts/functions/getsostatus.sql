CREATE OR REPLACE FUNCTION getSoStatus(INTEGER) RETURNS CHAR(1) AS $$
DECLARE
  pCoheadid ALIAS FOR $1;
  _result char(1);

BEGIN

  SELECT cohead_status INTO _result
  FROM cohead
  WHERE (cohead_id=pCoheadid);

  RETURN _result;

END;
$$ LANGUAGE 'plpgsql' STABLE;
