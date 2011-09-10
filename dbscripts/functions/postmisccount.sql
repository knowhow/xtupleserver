CREATE OR REPLACE FUNCTION postMiscCount(INTEGER, NUMERIC, TEXT) RETURNS INTEGER AS'
DECLARE
  pItemsiteid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pComments ALIAS FOR $3;
  _invcntid INTEGER;
  _result INTEGER;

BEGIN

  SELECT invcnt_id INTO _invcntid
  FROM invcnt
  WHERE ( (NOT invcnt_posted)
   AND (invcnt_itemsite_id=pItemsiteid) );

  IF (_invcntid IS NULL) THEN
    _invcntid := NEXTVAL(''invcnt_invcnt_id_seq'');

    INSERT INTO invcnt
     ( invcnt_id, invcnt_itemsite_id, invcnt_tagdate,
       invcnt_qoh_before, invcnt_qoh_after,
       invcnt_tag_username, invcnt_cntdate, invcnt_cnt_username,
       invcnt_postdate, invcnt_post_username, invcnt_posted,
       invcnt_priority, invcnt_comments )
    SELECT _invcntid, pItemsiteid, now(),
           itemsite_qtyonhand, pQty,
           getEffectiveXtUser(), now(), getEffectiveXtUser(),
           now(), getEffectiveXtUser(), FALSE,
           FALSE, pComments
    FROM itemsite
    WHERE (itemsite_id=pItemsiteid);

    SELECT postCountTag(_invcntid, FALSE) INTO _result;
    IF (_result < 0) THEN
      DELETE FROM invcnt
      WHERE (invcnt_id=_invcntid);
    END IF;

    RETURN _result;
  ELSE
    RETURN -2;
  END IF;

END;
' LANGUAGE 'plpgsql';
