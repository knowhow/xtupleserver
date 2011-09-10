
CREATE OR REPLACE FUNCTION formatindent(text,int4)
  RETURNS text AS '
DECLARE
  pText ALIAS FOR $1;
  pIndent ALIAS FOR $2;
  _i INTEGER;
  _result TEXT;

BEGIN
  _result := '''';
  _i := 0;

  WHILE _i < pIndent LOOP
    _result := _result || ''  '';
    _i := _i + 1;
  END LOOP;

  _result := _result || pText;
  RETURN _result;
END;
' LANGUAGE 'plpgsql' VOLATILE;

