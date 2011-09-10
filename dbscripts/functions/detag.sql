
CREATE OR REPLACE FUNCTION detag(TEXT) RETURNS TEXT IMMUTABLE AS $$
DECLARE
  pSource ALIAS FOR $1;
  _result TEXT := '';

BEGIN
  SELECT regexp_replace(pSource, E'<[^>]*>', '', 'g') INTO _result;
  RETURN _result;
END;
$$ LANGUAGE 'plpgsql';

