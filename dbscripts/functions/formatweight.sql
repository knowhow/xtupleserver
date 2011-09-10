CREATE OR REPLACE FUNCTION formatWeight(NUMERIC) RETURNS TEXT IMMUTABLE AS '
SELECT formatNumeric($1, ''weight'') AS result
' LANGUAGE 'sql';
