define ut3_user       = ut3
define ut3_password   = ut3
define ut3_tablespace = users

@@create_utplsql_owner.sql &&ut3_user &&ut3_password &&ut3_tablespace
@@install.sql &&ut3_user
@@create_synonyms_and_grants_for_public.sql &&ut3_user

exit
