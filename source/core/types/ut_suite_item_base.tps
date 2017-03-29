create or replace type ut_suite_item_base authid current_user as object (
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

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
  * Object type is a pre-declaration to be referenced by ut_event_listener_base
  * The true abstract type is ut_suite_item
  */
  self_type    varchar2(250 byte),
  /**
  * owner of the database object (package)
  */
  object_owner  varchar2(4000 byte),
  /**
  * name of the database object (package)
  */
  object_name   varchar2(4000 byte),
  /**
  * Name of the object (suite, sub-suite, test)
  */
  name          varchar2(4000 byte),
  /**
  * Description fo the suite item (as given by the annotation)
  */
  description   varchar2(4000 byte),

  /**
  * Full path of the invocation of the item (including the items name itself)
  */
  path          varchar2(4000 byte),
  /**
  * The type of the rollback behavior
  */
  rollback_type integer(1),
  /**
  * Indicates if the test is to be disabled by execution
  */
  disabled_flag integer(1),
  --execution result fields
  start_time    timestamp with time zone,
  end_time      timestamp with time zone,
  result        integer(1),
  warnings      ut_varchar2_list

)
not final not instantiable
/
