CREATE OR REPLACE FUNCTION cntctused(integer) RETURNS boolean AS $$
DECLARE
  pCntctId ALIAS FOR $1;
  _fk RECORD;
  _r RECORD;
  _seq INTEGER;
  _col TEXT;
  _qry TEXT;

BEGIN
  -- Determine where this contact is used by analyzing foreign key linkages
  FOR _fk IN
    SELECT pg_namespace.nspname AS schemaname, con.relname AS tablename, conkey AS seq, conrelid AS class_id 
    FROM pg_constraint, pg_class f, pg_class con, pg_namespace
    WHERE confrelid=f.oid
    AND conrelid=con.oid
    AND f.relname = 'cntct'
    AND con.relnamespace=pg_namespace.oid
    AND con.relname NOT IN ('cntctsel', 'cntctmrgd', 'mrghist','trgthist')
  LOOP
    -- Validate
    IF (ARRAY_UPPER(_fk.seq,1) > 1) THEN
      RAISE EXCEPTION 'Checks to tables where the contact is one of multiple foreign key columns is not supported. Error on Table: %',
        pg_namespace.nspname || '.' || con.relname;
    END IF;
    
    _seq := _fk.seq[1];

    -- Get the specific column name
    SELECT attname INTO _col
    FROM pg_attribute, pg_class
    WHERE ((attrelid=pg_class.oid)
    AND (pg_class.oid=_fk.class_id)
    AND (attnum=_seq));

    -- See if there are dependencies
    _qry := 'SELECT * 
            FROM ' || _fk.schemaname || '.' || _fk.tablename || '
            WHERE ('|| _col || '=' || pCntctId || ');';

    FOR _r IN 
      EXECUTE _qry
    LOOP
      RETURN true;
    END LOOP;
         
  END LOOP;

  -- Check for relationships without keys
  SELECT id INTO _r
  FROM (
  SELECT comment_id AS id
  FROM comment
  WHERE ((comment_source_id= pCntctId)
   AND (comment_source='T'))
  UNION
  SELECT docass_id AS id
  FROM docass
  WHERE ((docass_target_id= pCntctId)
   AND (docass_target_type='T'))
  UNION
  SELECT docass_id AS id
  FROM docass
  WHERE ((docass_source_id= pCntctId)
   AND (docass_source_type='T'))
  UNION
  SELECT vend_id AS id
  FROM vendinfo
  WHERE (vend_cntct1_id=pCntctId OR vend_cntct2_id=pCntctId)
  ) data;

  IF (FOUND) THEN
    RETURN true;
  END IF;

  RETURN false;

END;
$$ LANGUAGE 'plpgsql';