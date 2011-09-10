CREATE OR REPLACE FUNCTION getOpHeadId(text) RETURNS INTEGER AS '
DECLARE
  pOpHeadName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  
  IF (pOpHeadName IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT ophead_id INTO _returnVal
  FROM ophead
  WHERE (UPPER(ophead_name)=UPPER(pOpHeadName));
  
  IF (_returnVal IS NULL) THEN
      RAISE EXCEPTION ''Opportunity % not found.'', pOpHeadName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
