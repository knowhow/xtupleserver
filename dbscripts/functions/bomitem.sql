CREATE OR REPLACE FUNCTION bomitem(INTEGER) RETURNS SETOF bomitem AS '
DECLARE
  pItemid ALIAS FOR $1;
  _row bomitem%ROWTYPE;
  _revid INTEGER;

BEGIN

  SELECT getActiveRevId(''BOM'',pItemid) INTO _revid;
  
  FOR _row IN SELECT *
            FROM bomitem(pItemid,_revid)
  LOOP
    RETURN NEXT _row;
  END LOOP;

  RETURN;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION bomitem(INTEGER,INTEGER) RETURNS SETOF bomitem AS '
DECLARE
  pItemid ALIAS FOR $1;
  pRevid ALIAS FOR $2;
  _row bomitem%ROWTYPE;

BEGIN
  FOR _row IN SELECT *
            FROM bomitem
            WHERE ((bomitem_parent_item_id=pItemid)
            AND (bomitem_rev_id=pRevid))
  LOOP
    RETURN NEXT _row;
  END LOOP;

  RETURN;
END;
' LANGUAGE 'plpgsql';
