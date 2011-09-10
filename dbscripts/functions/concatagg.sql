CREATE OR REPLACE FUNCTION concataggSfunc(TEXT, TEXT) RETURNS TEXT AS $$
DECLARE
  prevstate     ALIAS FOR $1;
  newval        ALIAS FOR $2;
BEGIN
  RETURN prevstate || newval;
END;
$$
LANGUAGE 'plpgsql';

CREATE AGGREGATE concatagg (TEXT) (
  SFUNC = concataggSfunc,
  STYPE = TEXT,
  INITCOND = ''
);
