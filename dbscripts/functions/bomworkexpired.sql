CREATE OR REPLACE FUNCTION bomworkExpired( INTEGER, DATE ) RETURNS BOOLEAN AS '
DECLARE
    workid ALIAS FOR $1;
    expdate ALIAS FOR $2;
    _wid INTEGER;
    _bomwork RECORD;
BEGIN
    _wid := workid;
    WHILE (_wid != -1) LOOP
        SELECT bomwork_parent_id AS parent,
               bomwork_expires AS expires
          INTO _bomwork
          FROM bomwork
         WHERE bomwork_id=_wid;

         IF (FOUND) THEN
             _wid := _bomwork.parent;
             IF (_bomwork.expires <= expdate) THEN
                 RETURN TRUE;
             END IF;
         ELSE
             _wid := -1;
         END IF;
    END LOOP;
    RETURN FALSE;
END;
' LANGUAGE 'plpgsql';
