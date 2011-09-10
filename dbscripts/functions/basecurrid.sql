CREATE OR REPLACE FUNCTION baseCurrID ()
    RETURNS INTEGER IMMUTABLE AS $$
    DECLARE
	returnVal INTEGER;
    BEGIN
	SELECT curr_id INTO returnVal
	    FROM curr_symbol
	    WHERE curr_base = TRUE;
    	IF NOT FOUND THEN
	    RAISE EXCEPTION 'No base currency found';
	END IF;
	RETURN returnVal;
    END;
$$ LANGUAGE plpgsql;