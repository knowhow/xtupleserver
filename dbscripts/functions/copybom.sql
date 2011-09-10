CREATE OR REPLACE FUNCTION copyBOM(INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pSItemid ALIAS FOR $1;
  pTItemid ALIAS FOR $2;
  _result INTEGER;

BEGIN

  SELECT copyBOM (pSItemid, PTItemid, FALSE) into _result;

  RETURN _result;

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION copyBOM(INTEGER, INTEGER, BOOLEAN) RETURNS INTEGER AS $$
DECLARE
  pSItemid ALIAS FOR $1;
  pTItemid ALIAS FOR $2;
  pCopyUsedAt ALIAS FOR $3;
  _r RECORD;
  _bomitemid INTEGER;
  _bomworksetid INTEGER;
  _temp INTEGER;
  _schedatwooper BOOLEAN;
  _booitemseqid INTEGER;

BEGIN

--  Make sure that the parent is not used in the component at some level
  IF ( SELECT (item_type IN ('M', 'F'))
       FROM item
       WHERE (item_id=pSItemid) ) THEN
    SELECT indentedWhereUsed(pTItemid) INTO _bomworksetid;
    SELECT bomwork_id INTO _temp
    FROM bomwork
    WHERE ( (bomwork_set_id=_bomworksetid)
     AND (bomwork_item_id=pSItemid) )
    LIMIT 1;
    IF (FOUND) THEN
      PERFORM deleteBOMWorkset(_bomworksetid);
      RETURN -1;
    END IF;
    PERFORM deleteBOMWorkset(_bomworksetid);
  END IF;

  INSERT INTO bomhead
  ( bomhead_item_id, bomhead_serial, bomhead_docnum,
    bomhead_batchsize, bomhead_requiredqtyper )
  SELECT pTItemid, bomhead_serial, bomhead_docnum,
         bomhead_batchsize, bomhead_requiredqtyper
  FROM bomhead
  WHERE ((bomhead_item_id=pSItemid)
    AND  (bomhead_rev_id=getActiveRevID('BOM', pSItemid)));

  FOR _r IN SELECT bomitem.*
            FROM bomitem(pSItemid) 
            WHERE (bomitem_expires>CURRENT_DATE) LOOP

    SELECT NEXTVAL('bomitem_bomitem_id_seq') INTO _bomitemid;

    IF (pCopyUsedAt) THEN
      _schedatwooper := _r.bomitem_schedatwooper;
      _booitemseqid := _r.bomitem_booitem_seq_id;
    ELSE
      _schedatwooper := FALSE;
      _booitemseqid := -1;
    END IF;

    INSERT INTO bomitem
    ( bomitem_id, bomitem_parent_item_id, bomitem_seqnumber, bomitem_item_id,
      bomitem_uom_id, bomitem_qtyfxd, bomitem_qtyper, bomitem_scrap, bomitem_schedatwooper,
      bomitem_booitem_seq_id,
      bomitem_effective, bomitem_expires, bomitem_ecn,
      bomitem_createwo, bomitem_issuemethod, bomitem_moddate, bomitem_subtype,
      bomitem_notes, bomitem_ref )
    VALUES
    ( _bomitemid, pTItemid, _r.bomitem_seqnumber, _r.bomitem_item_id,
      _r.bomitem_uom_id, _r.bomitem_qtyfxd, _r.bomitem_qtyper, _r.bomitem_scrap, _schedatwooper,
      _booitemseqid,
      CURRENT_DATE, _r.bomitem_expires, _r.bomitem_ecn,
      _r.bomitem_createwo, _r.bomitem_issuemethod, CURRENT_DATE, _r.bomitem_subtype,
      _r.bomitem_notes, _r.bomitem_ref );

    INSERT INTO bomitemsub
    ( bomitemsub_bomitem_id, bomitemsub_item_id,
      bomitemsub_uomratio, bomitemsub_rank )
    SELECT _bomitemid, bomitemsub_item_id,
           bomitemsub_uomratio, bomitemsub_rank
    FROM bomitemsub
    WHERE (bomitemsub_bomitem_id=_r.bomitem_id);

  END LOOP;

  RETURN pTItemid;

END;
$$ LANGUAGE 'plpgsql';
