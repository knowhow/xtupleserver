
CREATE OR REPLACE FUNCTION deleteIpsProdCat(INTEGER) RETURNS INTEGER AS '
DECLARE
  pIpsProdCatId	ALIAS FOR $1;
BEGIN

  DELETE FROM ipsprodcat WHERE ipsprodcat_id=pIpsProdCatId;
  
  RETURN 1;
END;
' LANGUAGE 'plpgsql';

