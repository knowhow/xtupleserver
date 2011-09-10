CREATE OR REPLACE FUNCTION FetchMetricBool(text) RETURNS BOOLEAN STABLE AS '
DECLARE
  _pMetricName ALIAS FOR $1;
  _returnVal BOOLEAN;
BEGIN
  SELECT CASE 
    WHEN MIN(metric_value) = ''t'' THEN
     true
    ELSE
     false
    END INTO _returnVal
    FROM metric
   WHERE metric_name = _pMetricName;
  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
