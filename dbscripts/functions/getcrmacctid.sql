CREATE OR REPLACE FUNCTION getCrmAcctId(text) RETURNS INTEGER AS '
DECLARE
  pAcctNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  
  IF (pAcctNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT crmacct_id INTO _returnVal
  FROM crmacct
  WHERE (UPPER(crmacct_number)=UPPER(pAcctNumber));
  
  IF (_returnVal IS NULL) THEN
      RAISE EXCEPTION ''CRM Account Number % not found.'', pAcctNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';