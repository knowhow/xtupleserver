
CREATE OR REPLACE FUNCTION acknowledgeMessage(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pMsgid ALIAS FOR $1;

BEGIN

  UPDATE msguser
  SET msguser_viewed=CURRENT_TIMESTAMP
  WHERE ( (msguser_msg_id=pMsgid)
   AND (msguser_username=getEffectiveXtUser()) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

