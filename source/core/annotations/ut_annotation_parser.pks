create or replace package ut_annotation_parser authid current_user as
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
   * Parses the source passed as input parameter and returns annotations
   */

  /**
   * Runs the source lines through dbms_preprocessor to remove lines that were not compiled (conditional compilation)
   * Parses the processed source code and converts it to annotations
   *
   * @param a_source_lines ordered lines of source code to be parsed
   * @return array containing annotations
   */
  function parse_object_annotations(a_source_lines dbms_preprocessor.source_lines_t) return ut_annotations;


  /**
   *
   * @private
   * Parses source code and converts it to annotations
   *
   * @param a_source_lines ordered lines of source code to be parsed
   * @return array containing annotations
   */
  function parse_object_annotations(a_source clob) return ut_annotations;

end ut_annotation_parser;
/
