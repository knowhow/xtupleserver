CREATE OR REPLACE FUNCTION fetchshipmentnumber() RETURNS TEXT AS '
DECLARE
  _number		TEXT;
  _test			INTEGER;

BEGIN
  LOOP

    SELECT CAST(nextval(''shipment_number_seq'') AS TEXT) INTO _number;
    
    SELECT shiphead_id INTO _test
      FROM shiphead
     WHERE (shiphead_number=_number);
    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _number;
  
END;
' LANGUAGE 'plpgsql';



