CREATE OR REPLACE FUNCTION checkInvoiceSitePrivs(INTEGER) RETURNS BOOLEAN STABLE AS '
DECLARE
  pInvcheadid ALIAS FOR $1;
  _check    BOOLEAN;
  _result   INTEGER;

BEGIN

  IF (NOT fetchMetricBool(''MultiWhs'')) THEN
    RETURN true;
  END IF;

  IF (NOT fetchUsrPrefBool(''selectedSites'')) THEN
    RETURN true;
  END IF;

  SELECT COALESCE(COUNT(*), 0) INTO _result
    FROM ( SELECT invcitem_id
             FROM invcitem
            WHERE ( (invcitem_invchead_id=pInvcheadid)
              AND   (invcitem_warehous_id <> -1)
              AND   (invcitem_warehous_id NOT IN (SELECT usrsite_warehous_id
                                                    FROM usrsite
                                                   WHERE (usrsite_username=getEffectiveXtUser()))) )
         ) AS data;
  IF (_result > 0) THEN
    RETURN false;
  END IF;

  RETURN true;
END;
' LANGUAGE 'plpgsql';
