CREATE OR REPLACE FUNCTION detachCCPayFromSO(INTEGER, INTEGER, INTEGER)
  RETURNS INTEGER AS
'
DECLARE
  pcoheadid		ALIAS FOR $1;
  pwarehousid		ALIAS FOR $2;
  pcustid		ALIAS FOR $3;

BEGIN
  RAISE NOTICE ''detachCCPayFromSO(INTEGER, INTEGER, INTEGER): deprecated'';
  RETURN 0;
END;
'
LANGUAGE 'plpgsql';