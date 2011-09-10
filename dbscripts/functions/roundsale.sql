
CREATE OR REPLACE FUNCTION roundSale(NUMERIC) RETURNS NUMERIC AS $$
DECLARE
  _pSale ALIAS FOR $1;
  _scale INTEGER;

BEGIN
  IF (_pSale IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT locale_salesprice_scale INTO _scale
  FROM locale, usr
  WHERE ((usr_locale_id=locale_id)
     AND (usr_username=getEffectiveXtUser()));

  RETURN ROUND(_pSale, _scale);

END;
$$ LANGUAGE 'plpgsql';

