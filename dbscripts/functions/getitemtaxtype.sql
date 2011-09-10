CREATE OR REPLACE FUNCTION getItemTaxType(INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pItemid ALIAS FOR $1;
  pTaxzoneid ALIAS FOR $2;
  _taxtypeid INTEGER;
BEGIN
  SELECT itemtax_taxtype_id
    INTO _taxtypeid
    FROM itemtax
   WHERE ((itemtax_item_id=pItemid)
     AND  (itemtax_taxzone_id=pTaxzoneid));
  IF (NOT FOUND) THEN
    SELECT itemtax_taxtype_id
      INTO _taxtypeid
      FROM itemtax
     WHERE ((itemtax_item_id=pItemid)
       AND  (itemtax_taxzone_id IS NULL));
    IF (NOT FOUND) THEN
      RETURN NULL;
    END IF;
  END IF;

  RETURN _taxtypeid;
END;
$$ LANGUAGE 'plpgsql';
