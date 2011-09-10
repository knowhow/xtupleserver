CREATE OR REPLACE FUNCTION releaseCRMAccountNumber(INTEGER) RETURNS BOOLEAN AS $$
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a Inident exists with the passed Number
  SELECT id INTO _test
    FROM ( SELECT crmacct_id AS id
             FROM crmacct
            WHERE(crmacct_number=text(pNumber))
            UNION
           SELECT cust_id
             FROM custinfo
            WHERE (cust_number=text(pNumber))
            UNION
           SELECT prospect_id
             FROM prospect
            WHERE (prospect_number=text(pNumber))
            UNION
           SELECT vend_id
             FROM vendinfo
            WHERE (vend_number=text(pNumber))
            UNION
           SELECT taxauth_id
             FROM taxauth
            WHERE (taxauth_code=text(pNumber))
         ) AS data;

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if Number orderseq has been incremented past the passed Number
  SELECT orderseq_number INTO _test
    FROM orderseq
   WHERE (orderseq_name='CRMAccountNumber');

  IF ((_test - 1) <> pNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the Number orderseq, releasing the passed Number
  UPDATE orderseq
     SET orderseq_number = (orderseq_number - 1)
   WHERE (orderseq_name='CRMAccountNumber');

  RETURN TRUE;

END;
$$ LANGUAGE plpgsql;

