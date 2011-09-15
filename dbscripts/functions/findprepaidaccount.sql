
CREATE OR REPLACE FUNCTION findPrepaidAccount(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  _accntid INTEGER;

BEGIN

--  Check for a Customer Type specific Account
  SELECT araccnt_prepaid_accnt_id INTO _accntid
  FROM araccnt, cust
  WHERE ( (araccnt_custtype_id=cust_custtype_id)
   AND (cust_id=pCustid) );
  IF (FOUND) THEN
    RETURN _accntid;
  END IF;

--  Check for a Customer Type pattern
  SELECT araccnt_prepaid_accnt_id INTO _accntid
  FROM araccnt, cust, custtype
  WHERE ( (custtype_code ~ araccnt_custtype)
   AND (cust_custtype_id=custtype_id)
   AND (araccnt_custtype_id=-1)
   AND (cust_id=pCustid) );
  IF (FOUND) THEN
    RETURN _accntid;
  END IF;

  RETURN -1;

END;
$$ LANGUAGE 'plpgsql';

