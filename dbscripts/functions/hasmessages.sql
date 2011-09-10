
CREATE OR REPLACE FUNCTION hasMessages() RETURNS BOOLEAN AS '
BEGIN

  PERFORM msguser_id
  FROM msg, msguser
  WHERE ( (msguser_username=getEffectiveXtUser())
   AND (msguser_msg_id=msg_id)
   AND (CURRENT_TIMESTAMP BETWEEN msg_scheduled AND msg_expires)
   AND (msguser_viewed IS NULL) )
  LIMIT 1;
  RETURN FOUND;

END;
' LANGUAGE 'plpgsql';

