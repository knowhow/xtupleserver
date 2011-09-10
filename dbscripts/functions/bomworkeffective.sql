CREATE OR REPLACE FUNCTION bomworkEffective( INTEGER, DATE ) RETURNS BOOLEAN AS '
DECLARE
    workid ALIAS FOR $1;
    effdate ALIAS FOR $2;
    _wid INTEGER;
    _bomwork RECORD;
BEGIN
    _wid := workid;
    WHILE (_wid != -1) LOOP
        SELECT bomwork_parent_id AS parent,
               bomwork_effective AS effective
          INTO _bomwork
          FROM bomwork
         WHERE bomwork_id=_wid;

         IF (FOUND) THEN
             _wid := _bomwork.parent;
             IF (_bomwork.effective > effdate) THEN
                 RETURN FALSE;
             END IF;
         ELSE
             _wid := -1;
         END IF;
    END LOOP;
    RETURN TRUE;
END;
' LANGUAGE 'plpgsql';
