CREATE OR REPLACE FUNCTION woEffectiveDate(DATE) RETURNS DATE AS '
DECLARE
  pStartDate ALIAS FOR $1;

BEGIN

  IF (explodeWoEffective() = ''E'') THEN
    RETURN CURRENT_DATE;
  ELSE
    RETURN pStartDate;
  END IF;

END;
' LANGUAGE 'plpgsql';