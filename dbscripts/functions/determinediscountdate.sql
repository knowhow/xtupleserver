CREATE OR REPLACE FUNCTION determineDiscountDate(INTEGER, DATE) RETURNS DATE AS $$
DECLARE
  pTermsid ALIAS FOR $1;
  pSourceDate ALIAS FOR $2;
  _discDate DATE;
  _p RECORD;

BEGIN

  SELECT terms_type, terms_discdays, terms_cutoffday INTO _p
  FROM terms
  WHERE (terms_id=pTermsid);
  IF (NOT FOUND) THEN
    _discDate := pSourceDate;

--  Handle type D terms
  ELSIF (_p.terms_type = 'D') THEN
    _discDate := (pSourceDate + _p.terms_discdays);

--  Handle type P terms
  ELSIF (_p.terms_type = 'P') THEN
    IF (date_part('day', pSourceDate) <= _p.terms_cutoffday) THEN
      _discDate := (DATE(date_trunc('month', pSourceDate)) + (_p.terms_discdays - 1));
    ELSE
      _discDate := (DATE(date_trunc('month', pSourceDate)) + (_p.terms_discdays - 1) + INTERVAL '1 month');
    END IF;

--  Handle unknown terms
  ELSE
    _discDate := pSourceDate;
  END IF;

  RETURN _discDate;

END;
$$ LANGUAGE 'plpgsql';
