create or replace package ut_suite_cache_manager authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  /**
   * Responsible for storing and retrieving suite data from cache
   */

  procedure save_cache(a_object_owner varchar2, a_suite_items ut_suite_items);

  function get_schema_parse_time(a_schema_name varchar2) return timestamp result_cache;

end ut_suite_cache_manager;
/
