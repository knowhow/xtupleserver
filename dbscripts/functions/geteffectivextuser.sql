SELECT initEffectiveXtUser();

CREATE OR REPLACE FUNCTION getEffectiveXtUser() RETURNS TEXT AS $$
  SELECT COALESCE( (SELECT effective_value
                    FROM effective_user
                    WHERE effective_key = 'username'), current_user);
$$ LANGUAGE 'sql';

