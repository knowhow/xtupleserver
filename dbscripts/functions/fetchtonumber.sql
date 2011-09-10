CREATE OR REPLACE FUNCTION fetchToNumber() RETURNS TEXT AS '
BEGIN
  RETURN fetchNextNumber(''ToNumber'');
END;
' LANGUAGE 'plpgsql';
