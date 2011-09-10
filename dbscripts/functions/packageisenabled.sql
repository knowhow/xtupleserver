CREATE OR REPLACE FUNCTION packageIsEnabled(INTEGER) RETURNS BOOLEAN AS $$
  SELECT COUNT(*) >= 8
  FROM pg_inherits, pg_class, pg_namespace, pkghead
  WHERE ((inhrelid=pg_class.oid)
     AND (relnamespace=pg_namespace.oid)
     AND  (nspname=lower(pkghead_name))
     AND  (pkghead_id=$1));
$$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION packageIsEnabled(TEXT) RETURNS BOOLEAN AS $$
  SELECT COUNT(*) >= 8
  FROM pg_inherits, pg_class, pg_namespace
  WHERE ((inhrelid=pg_class.oid)
     AND (relnamespace=pg_namespace.oid)
     AND  (nspname=lower($1)));
$$
LANGUAGE 'sql';
