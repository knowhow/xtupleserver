
CREATE OR REPLACE FUNCTION postComment(INTEGER, TEXT, INTEGER, TEXT) RETURNS INTEGER AS $$
DECLARE
  pCmnttypeid ALIAS FOR $1;
  pSource ALIAS FOR $2;
  pSourceid ALIAS FOR $3;
  pText ALIAS FOR $4;
BEGIN
  RETURN postComment(pCmnttypeid, pSource, pSourceid, pText, NULL);
END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION postComment(INTEGER, TEXT, INTEGER, TEXT, BOOLEAN) RETURNS INTEGER AS $$
DECLARE
  pCmnttypeid ALIAS FOR $1;
  pSource ALIAS FOR $2;
  pSourceid ALIAS FOR $3;
  pText ALIAS FOR $4;
  pPublic ALIAS FOR $5;
  _commentid INTEGER;
  _public BOOLEAN;
BEGIN

  _public := COALESCE(pPublic, fetchmetricbool('CommentPublicDefault'));

  SELECT NEXTVAL('comment_comment_id_seq') INTO _commentid;

  INSERT INTO comment
  ( comment_id, comment_cmnttype_id, comment_source, comment_source_id,
    comment_date, comment_user, comment_text, comment_public )
  VALUES
  ( _commentid, pCmnttypeid, pSource, pSourceid,
    CURRENT_TIMESTAMP, getEffectiveXtUser(), pText, _public );

  RETURN _commentid;

END;
$$ LANGUAGE 'plpgsql';

