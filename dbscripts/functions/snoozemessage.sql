
CREATE OR REPLACE FUNCTION snoozeMessage(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pMsgid ALIAS FOR $1;
  snooze INTERVAL := ''10 minutes'';

BEGIN

  UPDATE msg
  SET msg_scheduled=(msg_scheduled + snooze)
  WHERE (msg_id=pMsgid);

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

