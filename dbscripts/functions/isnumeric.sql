
CREATE OR REPLACE FUNCTION isNumeric(TEXT) RETURNS BOOLEAN IMMUTABLE AS '
DECLARE
  pText ALIAS FOR $1;
  _cursor INTEGER;

BEGIN

  IF ( (LENGTH(pText) = 0) OR (pText IS NULL) ) THEN
    RETURN FALSE;
  END IF;

  FOR _cursor IN 1..LENGTH(pText) LOOP
    IF (SUBSTRING(pText FROM _cursor FOR 1) NOT IN ( ''0'', ''1'', ''2'', ''3'', ''4'',
                                                     ''5'' ,''6'' ,''7'' ,''8'' ,''9'' )) THEN
      RETURN FALSE;
    END IF;
  END LOOP;

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

