create or replace package ut_annotation_parser authid current_user as
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

  /*
    package: ut_annotation_parser

    Responsible for parsing and accessing utplsql annotations.

  */

  subtype t_annotation_name is varchar2(1000);
  subtype t_procedure_name  is varchar2(250);

  /*
    type: typ_annotation_param

    a key/value pair of annotation parameters

    example:
      --%test(name=A name of the test)
    will be stored as:
      typ_annotation_param( key=> 'name', value=>'A name of the test' )
  */
  type typ_annotation_param is record(
     key   varchar2(255)
    ,val   varchar2(4000));

  /*
    type: typ_annotation_param
    a list of typ_annotation_param
  */
  type tt_annotation_params is table of typ_annotation_param index by pls_integer;

  type t_object_source is record(
    owner      varchar2(250),
    name       varchar2(250),
    type       varchar2(50),
    cache_id   integer,
    lines      ut_varchar2_rows
  );

  type t_object_sources_cur is ref cursor return t_object_source;

  /*
    INTERNAL USE ONLY
  */
  function parse_package_annotations(a_source clob) return ut_annotations;

  function parse_annotations(a_cursor t_object_sources_cur) return ut_annotated_objects pipelined;

  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2) return ut_annotated_objects pipelined;

  /*
    function: get_package_annotations

    get annotations for specified package specification and return its annotated schema
  */
  function get_package_annotations(a_owner_name varchar2, a_name varchar2) return ut_annotations;

  function get_post_processed_source(a_source_lines ut_varchar2_rows) return clob;


  /*
    function: parse_annotation_params

    parses annotation parameters from annotation text string
  */
  function parse_annotation_params(a_annotation_text varchar2) return tt_annotation_params;

end ut_annotation_parser;
/
