CREATE OR REPLACE FUNCTION bomLevelByItem(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pItemid ALIAS FOR $1;
  _cnt INTEGER;
  _result INTEGER;
  _bomitem RECORD;

BEGIN
  _cnt := 0;

  BEGIN
  FOR _bomitem IN SELECT bomitem_parent_item_id
                    FROM bomitem
                   WHERE (bomitem_item_id=pItemid) LOOP
    SELECT bomLevelByItem(_bomitem.bomitem_parent_item_id) + 1 INTO _result;
    IF (_result > _cnt) THEN
      _cnt := _result;
    END IF;
  END LOOP;
  EXCEPTION WHEN statement_too_complex THEN
      RAISE EXCEPTION 'potential recursive BOM found for item_id %', pItemid;
  END;

  return _cnt;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION bomLevelByItem(INTEGER,INTEGER) RETURNS INTEGER AS $$
DECLARE
  pItemid ALIAS FOR $1;
  pBomrevid ALIAS FOR $2;
  _cnt INTEGER;
  _result INTEGER;
  _bomitem RECORD;

BEGIN
  _cnt := 0;

  BEGIN
  FOR _bomitem IN SELECT bomitem_parent_item_id
                    FROM bomitem
                   WHERE ((bomitem_item_id=pItemid)
                     AND  (bomitem_rev_id=pBomrevid)) LOOP
    SELECT bomLevelByItem(_bomitem.bomitem_parent_item_id, pBomrevid) + 1 INTO _result;
    IF (_result > _cnt) THEN
      _cnt := _result;
    END IF;
  END LOOP;
  EXCEPTION WHEN statement_too_complex THEN
      RAISE EXCEPTION 'potential recursive BOM found for item_id %', pItemid;
  END;

  return _cnt;
END;
$$ LANGUAGE 'plpgsql';
