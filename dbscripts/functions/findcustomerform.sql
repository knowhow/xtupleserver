CREATE OR REPLACE FUNCTION findCustomerForm(INTEGER, CHARACTER(1)) RETURNS TEXT AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pFormtype ALIAS FOR $2;
  _f RECORD;
  _found BOOLEAN;

BEGIN

--  Check for a Customer Type specific Form
  SELECT custform.* INTO _f
  FROM custform, cust
  WHERE ( (custform_custtype_id=cust_custtype_id)
   AND (cust_id=pCustid) );

  IF (FOUND) THEN
    _found := TRUE;
  ELSE
--  Check for a Customer Type pattern
    SELECT custform.* INTO _f
    FROM custform, cust, custtype
    WHERE ( (custform_custtype_id=-1)
     AND (custtype_code ~ custform_custtype)
     AND (cust_custtype_id=custtype_id)
     AND (cust_id=pCustid) );

    IF (FOUND) THEN
      _found := TRUE;
    ELSE
      _found := FALSE;
    END IF;
  END IF;

  IF (_found) THEN
    IF ( (pFormType = 'I') AND (_f.custform_invoice_report_name IS NOT NULL) ) THEN
      RETURN _f.custform_invoice_report_name;

    ELSIF ( (pFormType = 'C') AND (_f.custform_creditmemo_report_name IS NOT NULL) ) THEN
      RETURN _f.custform_creditmemo_report_name;

    ELSIF ( (pFormType = 'S') AND (_f.custform_statement_report_name IS NOT NULL) ) THEN
      RETURN _f.custform_statement_report_name;

    ELSIF ( (pFormType = 'Q') AND (_f.custform_quote_report_name IS NOT NULL) ) THEN
      RETURN _f.custform_quote_report_name;

    ELSIF ( (pFormType = 'P') AND (_f.custform_packinglist_report_name IS NOT NULL) ) THEN
      RETURN _f.custform_packinglist_report_name;

    ELSIF ( (pFormType = 'L') AND (_f.custform_sopicklist_report_name IS NOT NULL) ) THEN
      RETURN _f.custform_sopicklist_report_name;
    END IF;


  END IF;

  IF (pFormType = 'I') THEN
    RETURN 'Invoice';
  ELSIF (pFormType = 'C') THEN
    RETURN 'CreditMemo';
  ELSIF (pFormType = 'S') THEN
    RETURN 'Statement';
  ELSIF (pFormType = 'Q') THEN
    RETURN 'Quote';
  ELSIF (pFormType = 'P') THEN
    RETURN 'PackingList-Shipment';
  ELSIF (pFormType = 'L') THEN
    RETURN 'PackingList';
  END IF;

END;
$$ LANGUAGE 'plpgsql';
