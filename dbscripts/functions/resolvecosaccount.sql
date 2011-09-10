CREATE OR REPLACE FUNCTION resolveCOSAccount(INTEGER, INTEGER) RETURNS INTEGER STABLE AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pCustid ALIAS FOR $2;
  _salesaccntid INTEGER;
  _accntid INTEGER;

BEGIN

  SELECT findSalesAccnt(pItemsiteid, pCustid) INTO _salesaccntid;
  IF (_salesaccntid = -1) THEN
    SELECT getUnassignedAccntId() INTO _accntid;
  ELSE
    SELECT salesaccnt_cos_accnt_id INTO _accntid
    FROM salesaccnt
    WHERE (salesaccnt_id=_salesaccntid);
  END IF;

  RETURN _accntid;

END;
$$ LANGUAGE 'plpgsql';