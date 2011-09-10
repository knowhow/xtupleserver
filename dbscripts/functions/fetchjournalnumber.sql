CREATE OR REPLACE FUNCTION fetchjournalnumber(TEXT) RETURNS INTEGER AS '
DECLARE
  pUse ALIAS FOR $1;
  _number INTEGER;

BEGIN

  SELECT nextval(''journal_number_seq'') INTO _number;

  INSERT INTO jrnluse
  (jrnluse_date, jrnluse_number, jrnluse_use)
  VALUES
  (CURRENT_TIMESTAMP, _number, pUse);

  RETURN _number;
  
END;
' LANGUAGE 'plpgsql';

