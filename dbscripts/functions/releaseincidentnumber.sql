CREATE OR REPLACE FUNCTION releaseIncidentNumber(INTEGER) RETURNS BOOLEAN AS $$
DECLARE
  pNumber ALIAS FOR $1;

BEGIN

  RETURN (releaseNumber('IncidentNumber', pNumber) = 1);

END;
$$ LANGUAGE plpgsql;

