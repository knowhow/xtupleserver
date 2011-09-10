CREATE OR REPLACE FUNCTION formatSoitemNumber(INTEGER) RETURNS TEXT AS $$
DECLARE
  targetSoitemid ALIAS FOR $1;
BEGIN
  RETURN ( SELECT (cohead_number::TEXT || '-' || formatsolinenumber(coitem_id))
           FROM cohead, coitem
           WHERE ((coitem_cohead_id=cohead_id)
            AND (coitem_id=targetSoitemid)) );
END;
$$ LANGUAGE 'plpgsql';
