
CREATE OR REPLACE FUNCTION roundCost(NUMERIC) RETURNS NUMERIC AS $$
DECLARE
  _pCost ALIAS FOR $1;

  _scale INTEGER;

BEGIN
  IF (_pCost IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT locale_cost_scale INTO _scale
  FROM locale, usr
  WHERE ((usr_locale_id=locale_id)
     AND (usr_username=getEffectiveXtUser()));

  RETURN ROUND(_pCost, _scale);

END;
$$ LANGUAGE 'plpgsql';

