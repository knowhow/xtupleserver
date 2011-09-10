CREATE OR REPLACE FUNCTION postbillingselection(integer)
  RETURNS integer AS
$BODY$
DECLARE
  pCobmiscid ALIAS FOR $1;

BEGIN

  RAISE NOTICE 'postBillingselection(integer) has been deprecated.  Please use createInvoice(integer).';
  RETURN createInvoice(pCobmiscid);

END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;