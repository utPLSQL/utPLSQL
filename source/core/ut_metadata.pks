create or replace package ut_metadata authid current_user as
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
  
  /*
    package: ut_metadata
  
    Common place for all code that reads from the system tables.
  
  */

  /*
    function: form_name
      
    forms correct object/subprogram name to call as owner.object[.subprogram]
    
  */
  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2;

  /*
    function: package_valid
  
    check if package exists and is VALID.
  
  */
  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean;

  /*
    function: procedure_exists
  
    check if package exists and is VALID and contains the given procedure.
  
  */
  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean;

  /*
    procedure: do_resolve

    resolves [owner.]object using dbms_utility.name_resolve and returnes resolved parts

  */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2);

  /*
    procedure: do_resolve
    
    resolves [owner.]object[.procedure] using dbms_utility.name_resolve and returnes resolved parts 
    
  */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2);

  /*
    function: get_package_spec_source

    return the text of the package specification for a given package
  */
  function get_package_spec_source(a_owner varchar2, a_object_name varchar2) return clob;


  /*
    function: get_source_definition_line

    return the text of the souce line for a given object, excludes package spec
  */
  function get_source_definition_line(a_owner varchar2, a_object_name varchar2, a_line_no integer) return varchar2;

end ut_metadata;
/
