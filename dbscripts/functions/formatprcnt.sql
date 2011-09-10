
CREATE OR REPLACE FUNCTION formatPrcnt(NUMERIC) RETURNS TEXT IMMUTABLE AS '
SELECT formatNumeric($1 * 100, ''percent'')  AS result
' LANGUAGE 'sql';

