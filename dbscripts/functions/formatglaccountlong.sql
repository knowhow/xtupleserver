
CREATE OR REPLACE FUNCTION formatGLAccountLong(INTEGER) RETURNS TEXT IMMUTABLE AS '
DECLARE
  pAccntid ALIAS FOR $1;
  _result TEXT;

BEGIN

  SELECT (formatGLAccount(accnt_id) || ''-'' || accnt_descrip) INTO _result
  FROM accnt
  WHERE (accnt_id=pAccntid);

  RETURN _result;

END;
' LANGUAGE 'plpgsql';

