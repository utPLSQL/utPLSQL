/*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
define ut3_user       = ut3
define ut3_password   = ut3
define ut3_tablespace = users

@@create_utplsql_owner.sql &&ut3_user &&ut3_password &&ut3_tablespace
@@install.sql &&ut3_user
@@create_synonyms_and_grants_for_public.sql &&ut3_user

exit
