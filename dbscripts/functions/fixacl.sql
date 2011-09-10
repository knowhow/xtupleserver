
CREATE OR REPLACE FUNCTION fixACL() RETURNS INTEGER AS $$
DECLARE
  _r     RECORD;
  _count INTEGER := 0;
  _name  TEXT;
  _oldgrp BOOLEAN := false;

BEGIN
  SELECT groname INTO _name FROM pg_group WHERE groname = 'openmfg';
  IF (FOUND) THEN
    _oldgrp := true;
  END IF;
  
  FOR _r IN SELECT relname, nspname
            FROM pg_catalog.pg_class c, pg_namespace n
            WHERE ((n.oid=c.relnamespace)
              AND  (nspname in ('public', 'api'))
              AND  (relkind in ('S', 'r', 'v'))) LOOP

    RAISE NOTICE '%.%', _r.nspname, _r.relname;
    
    IF (_oldgrp) THEN
      EXECUTE 'REVOKE ALL ON ' || _r.nspname || '.' || _r.relname || ' FROM openmfg;';
    END IF;
    EXECUTE 'REVOKE ALL ON ' || _r.nspname || '.' || _r.relname || ' FROM PUBLIC;';
    EXECUTE 'GRANT ALL ON '  || _r.nspname || '.' || _r.relname || ' TO GROUP xtrole;';
    _count := _count + 1;

  END LOOP;

  RETURN _count;
END;
$$ LANGUAGE 'plpgsql';

