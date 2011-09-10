CREATE OR REPLACE FUNCTION unmergecrmaccount(INTEGER) RETURNS BOOLEAN AS $$
DECLARE
  pCrmaccountId ALIAS FOR $1;
  _r   RECORD;
  _qry TEXT;

BEGIN
  IF (NOT EXISTS(SELECT 1
                   FROM mrgundo
                  WHERE mrgundo_base_schema='public'
                    AND mrgundo_base_table='crmacct'
                    AND mrgundo_base_id=pCrmaccountId)) THEN
    RETURN FALSE;
  END IF;
  
  FOR _r IN
    SELECT * FROM mrgundo
     WHERE ((mrgundo_base_schema='public')
        AND (mrgundo_base_table='crmacct')
        AND (mrgundo_base_id=pCrmaccountId)) THEN
  LOOP
    _qry := 'UPDATE ' || quote_ident(_r.mrgundo_schema)  ||
                  '.' || quote_ident(_r.mrgundo_table)
              ' SET ' || quote_ident(_r.mrgundo_col)     ||
            '= CAST(' || quote_literal(_r.mrgundo_value) || ' AS '
                      || quote_ident(_r.mrgundo_type)    || ')
              WHERE (' || _r.mrgundo_pkey_col || '=' || _r.mrgundo_pkey_id || ');';
    
    EXECUTE _qry;
         
  END LOOP;

  DELETE FROM mrgundo
   WHERE ((mrgundo_base_schema='public'
      AND (mrgundo_base_table='crmacct')
      AND (mrgundo_base_id=pCrmaccountId));

  RETURN TRUE;

END;
$$ LANGUAGE 'plpgsql';
