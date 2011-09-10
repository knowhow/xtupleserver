CREATE OR REPLACE FUNCTION moveBomitemDown(INTEGER) RETURNS INTEGER AS '
DECLARE
  pBomitemid ALIAS FOR $1;
  _nextBomitem RECORD;

BEGIN

  SELECT nextbomitem.bomitem_id, nextbomitem.bomitem_seqnumber AS next_seqnumber,
         thisbomitem.bomitem_seqnumber AS this_seqnumber INTO _nextBomitem
  FROM bomitem AS nextbomitem, bomitem AS thisbomitem
  WHERE ((nextbomitem.bomitem_seqnumber > thisbomitem.bomitem_seqnumber)
   AND (nextbomitem.bomitem_parent_item_id=thisbomitem.bomitem_parent_item_id)
   AND (nextbomitem.bomitem_rev_id=thisbomitem.bomitem_rev_id)
   AND (thisbomitem.bomitem_id=pBomitemid))
  ORDER BY next_seqnumber
  LIMIT 1;

  IF (FOUND) THEN
--  Swap the seqnumber of the current bomitem and the next bomitem

    UPDATE bomitem
    SET bomitem_seqnumber=NULL
    WHERE (bomitem_id=_nextBomitem.bomitem_id);

    UPDATE bomitem
    SET bomitem_seqnumber=_nextBomitem.next_seqnumber
    WHERE (bomitem_id=pBomitemid);

    UPDATE bomitem
    SET bomitem_seqnumber=_nextBomitem.this_seqnumber
    WHERE (bomitem_id=_nextBomitem.bomitem_id);
  END IF;

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
