CREATE OR REPLACE FUNCTION postbillingselectionconsolidated(integer)
  RETURNS integer AS
$BODY$
DECLARE
  pCustid ALIAS FOR $1;

BEGIN

  RAISE NOTICE 'postBillingselectionConsolidated(integer) has been deprecated.  Please use createInvoiceConsolidated(integer).';
  RETURN createInvoiceConsolidated(pCustid);

END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;