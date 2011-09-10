CREATE OR REPLACE FUNCTION userCanCreateUsers(TEXT) RETURNS BOOLEAN AS '
SELECT usesuper FROM pg_user
WHERE usename=($1);
' LANGUAGE 'sql';
