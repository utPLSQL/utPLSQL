create or replace package ut_trigger_check authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
   * checks if the trigger &&UT3_OWNER._PARSE is enabled and operational.
   */
  function is_alive return boolean;

  /**
  * If called from a DDL trigger sets alive flag to true.
  * If called outside of DDL trigger, sets alive flag to false.
  */
  procedure is_alive;

end;
/
