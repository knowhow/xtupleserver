CREATE OR REPLACE FUNCTION FetchDefaultShipVia() RETURNS TEXT AS '
DECLARE
  _returnVal TEXT;
BEGIN
  SELECT shipvia_code INTO _returnVal
  FROM shipvia
  WHERE shipvia_id=
	(SELECT CAST(metric_value AS integer)
	FROM metric
	WHERE metric_name = ''DefaultShipViaId'');
  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
