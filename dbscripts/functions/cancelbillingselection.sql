CREATE OR REPLACE FUNCTION cancelBillingSelection(INTEGER) RETURNS INTEGER AS '
DECLARE
  pCobmiscid ALIAS FOR $1;

BEGIN

  IF ( ( SELECT cobmisc_posted
         FROM cobmisc
         WHERE (cobmisc_id=pCobmiscid) ) ) THEN
    RETURN -1;
  END IF;

  DELETE FROM cobill
  WHERE (cobill_cobmisc_id=pCobmiscid); 

  DELETE FROM cobmisc
  WHERE (cobmisc_id=pCobmiscid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
