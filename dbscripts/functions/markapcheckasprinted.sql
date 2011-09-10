CREATE OR REPLACE FUNCTION markAPCheckAsPrinted(INTEGER) RETURNS INTEGER AS '
BEGIN
  RAISE NOTICE ''markAPCheckAsPrinted() is deprecated - use markCheckAsPrinted()'';
  RETURN markCheckAsPrinted($1);
END;
' LANGUAGE 'plpgsql';
