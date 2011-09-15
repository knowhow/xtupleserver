CREATE OR REPLACE FUNCTION findARAccount(INTEGER) RETURNS INTEGER STABLE AS $$
DECLARE
  pCustid ALIAS FOR $1;
  _accntid INTEGER;

BEGIN

--  Check for a Customer Type specific Account
  SELECT araccnt_ar_accnt_id INTO _accntid
  FROM araccnt, custinfo
  WHERE ( (araccnt_custtype_id=cust_custtype_id)
   AND (cust_id=pCustid) );
  IF (FOUND) THEN
    RETURN _accntid;
  END IF;

--  Check for a Customer Type pattern
  SELECT araccnt_ar_accnt_id INTO _accntid
  FROM araccnt, custinfo, custtype
  WHERE ( (custtype_code ~ araccnt_custtype)
   AND (araccnt_custtype_id=-1)
   AND (cust_custtype_id=custtype_id)
   AND (cust_id=pCustid) );
  IF (FOUND) THEN
    RETURN _accntid;
  END IF;

  RETURN -1;

END;
$$ LANGUAGE 'plpgsql';
