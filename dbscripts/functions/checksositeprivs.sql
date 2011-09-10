CREATE OR REPLACE FUNCTION checkSOSitePrivs(INTEGER) RETURNS BOOLEAN STABLE AS '
DECLARE
  pSoheadid ALIAS FOR $1;
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
    FROM ( SELECT coitem_id
             FROM coitem, itemsite
            WHERE ( (coitem_cohead_id=pSoheadid)
              AND   (coitem_itemsite_id=itemsite_id)
              AND   (itemsite_warehous_id NOT IN (SELECT usrsite_warehous_id
                                                    FROM usrsite
                                                   WHERE (usrsite_username=getEffectiveXtUser()))) )
           UNION
           SELECT cohead_warehous_id
             FROM cohead
            WHERE ( (cohead_id=pSoheadid)
              AND   (cohead_warehous_id NOT IN (SELECT usrsite_warehous_id
                                                  FROM usrsite
                                                 WHERE (usrsite_username=getEffectiveXtUser()))) )
         ) AS data;
  IF (_result > 0) THEN
    RETURN false;
  END IF;

  RETURN true;
END;
' LANGUAGE 'plpgsql';