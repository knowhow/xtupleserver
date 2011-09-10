CREATE OR REPLACE FUNCTION _custtypeTrigger () RETURNS TRIGGER AS '
DECLARE
  _check      BOOLEAN;
  _code       TEXT;

BEGIN

--  Checks
  IF (TG_OP IN (''INSERT'',''UPDATE'')) THEN

    IF (LENGTH(COALESCE(NEW.custtype_code, ''''))=0) THEN
      RAISE EXCEPTION ''You must supply a valid Customer Type Code.'';
    END IF;

    SELECT custtype_code INTO _code
    FROM custtype
    WHERE ( (UPPER(custtype_code)=UPPER(NEW.custtype_code))
      AND (custtype_id<>NEW.custtype_id) );
    IF (FOUND) THEN
      RAISE EXCEPTION ''The Customer Type Code entered cannot be used as it is in use.'';
    END IF;

  END IF;
  
  IF (TG_OP = ''DELETE'') THEN
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'custtypeTrigger');
CREATE TRIGGER custtypeTrigger BEFORE INSERT OR UPDATE OR DELETE ON custtype FOR EACH ROW EXECUTE PROCEDURE _custtypeTrigger();
