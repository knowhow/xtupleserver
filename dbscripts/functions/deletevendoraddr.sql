CREATE OR REPLACE FUNCTION deleteVendorAddress(INTEGER) RETURNS INTEGER  AS '
DECLARE
  pVendaddrid ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if the passed vendor address is used in pohead
  SELECT pohead_id INTO _test
  FROM pohead
  WHERE (pohead_vendaddr_id=pVendaddrid)
  LIMIT 1;
  IF (FOUND) THEN
    RETURN -1;
  END IF;

--  Delete the passed vendor address
  DELETE FROM vendaddrinfo
  WHERE (vendaddr_id=pVendaddrid);

  RETURN 0;

END;
' LANGUAGE 'plpgsql';
