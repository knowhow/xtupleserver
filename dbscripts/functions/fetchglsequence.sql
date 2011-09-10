
CREATE OR REPLACE FUNCTION fetchGLSequence() RETURNS INTEGER AS '
DECLARE
  _sequence INTEGER;

BEGIN

    SELECT NEXTVAL(''gltrans_sequence_seq'') INTO _sequence;
    RETURN _sequence;

END;
' LANGUAGE 'plpgsql';

