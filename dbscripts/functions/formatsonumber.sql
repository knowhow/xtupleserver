CREATE OR REPLACE FUNCTION formatSoNumber(INTEGER) RETURNS TEXT AS '
SELECT COALESCE((SELECT (text(cohead_number) || ''-'' || formatSoLineNumber(coitem_id))
                   FROM coitem JOIN cohead ON (coitem_cohead_id=cohead_id)
                  WHERE (coitem_id=($1))),''DELETED'');
' LANGUAGE 'SQL' STABLE;
