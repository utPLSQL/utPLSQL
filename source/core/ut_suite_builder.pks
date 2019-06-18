create or replace package ut_suite_builder authid current_user is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
   * Responsible for converting annotations into unit test suites
   */

  /**
   * Creates a list of suite items for an annotated object
   */
  procedure create_suite_item_list(
    a_annotated_object ut_annotated_object,
    a_suite_items out nocopy ut_suite_items
  );

end ut_suite_builder;
/
