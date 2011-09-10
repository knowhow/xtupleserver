
CREATE OR REPLACE FUNCTION numOfServerUsers() RETURNS INTEGER AS '
DECLARE
  _count INTEGER;

BEGIN

  SELECT COUNT(*) INTO _count
  FROM pg_stat_activity;
  IF (_count IS NULL) THEN
    _count := 0;
  END IF;

  RETURN _count;

END;
' LANGUAGE 'plpgsql';

