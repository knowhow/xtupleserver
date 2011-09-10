CREATE OR REPLACE FUNCTION deleteexpiredips() RETURNS BOOLEAN AS $$
DECLARE
  _r RECORD;

BEGIN

  FOR _r IN SELECT ipshead_id
    FROM ipshead
    WHERE (ipshead_expires <= current_date)
  LOOP

    DELETE FROM ipsass
      WHERE (ipsass_ipshead_id=_r.ipshead_id);
    DELETE FROM ipsitem
      WHERE (ipsitem_ipshead_id=_r.ipshead_id);
    DELETE FROM ipsfreight
      WHERE (ipsfreight_ipshead_id=_r.ipshead_id);
    DELETE FROM ipsprodcat
      WHERE (ipsprodcat_ipshead_id=_r.ipshead_id);
    DELETE FROM ipshead
      WHERE (ipshead_id=_r.ipshead_id);
  END LOOP;

  RETURN TRUE;

END;
$$ LANGUAGE 'plpgsql';