create or replace package body ut_coverage_helper is
  /*
  utPLSQL - Version 3
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


  g_develop_mode boolean not null := false;
  g_is_started   boolean not null := false;


  type t_proftab_row is record (
      line  binary_integer,
      calls number(38,0)
    );
    
  type t_proftab_rows is table of t_proftab_row;

  type t_block_row is record(
       line           binary_integer
      ,blocks         binary_integer
      ,covered_blocks binary_integer);
  
  type t_block_rows is table of t_block_row;

  procedure set_coverage_type(a_coverage_type in varchar2) is
  begin
    g_coverage_type := a_coverage_type;
  end;

  procedure set_coverage_status(a_started in boolean) is
  begin
   g_is_started := a_started;
  end;
  
  procedure set_develop_mode(a_develop_mode in boolean) is
  begin
   g_develop_mode := a_develop_mode;
  end;

  function get_coverage_type return varchar2 is
  begin
    return g_coverage_type;
  end;
  
  function get_coverage_id(a_coverage_type in varchar2) return integer is
  begin
   return g_coverage_id(a_coverage_type);
  end;

  function is_develop_mode return boolean is
  begin
    return g_develop_mode;
  end;

  procedure coverage_start_internal(a_run_comment varchar2,a_coverage_type in varchar2)  is
  begin
    set_coverage_type(a_coverage_type);
    if get_coverage_type = ut_coverage.gc_block_coverage then
      $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
       ut_block_coverage_helper.coverage_start(a_run_comment => a_run_comment ,a_coverage_id => g_coverage_id(ut_coverage.gc_block_coverage) );
      $else
       raise_application_error(ut_utils.gc_invalid_coverage_type,'Invalid coverage type requested. Please validate your Oracle install');
      $end
    elsif get_coverage_type = ut_coverage.gc_extended_coverage then
      $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
       ut_block_coverage_helper.coverage_start(a_run_comment => a_run_comment ,a_coverage_id => g_coverage_id(ut_coverage.gc_block_coverage) );
       ut_proftab_helper.coverage_start(a_run_comment => a_run_comment, a_coverage_id => g_coverage_id(ut_coverage.gc_proftab_coverage));
       coverage_pause();
      $else
       raise_application_error(ut_utils.gc_invalid_coverage_type,'Invalid coverage type requested. Please validate your Oracle install');
      $end
    else
       ut_proftab_helper.coverage_start(a_run_comment => a_run_comment, a_coverage_id => g_coverage_id(ut_coverage.gc_proftab_coverage));
       coverage_pause();
    end if;
    g_is_started := true;
  end;

  procedure coverage_start(a_run_comment varchar2,a_coverage_type in varchar2) is
  begin
    if not g_is_started then
      g_develop_mode := false;
      coverage_start_internal(a_run_comment,a_coverage_type);
    end if;
  end;

  procedure coverage_start_develop(a_coverage_type in varchar2) is
  begin
    if not g_is_started then
      g_develop_mode := true;
      coverage_start_internal('utPLSQL Code coverage run in development MODE '||ut_utils.to_string(systimestamp),a_coverage_type);
    end if;
  end;

  procedure coverage_pause is
  begin
    if not g_develop_mode then
      if get_coverage_type = ut_coverage.gc_block_coverage then
         null;
      else
         ut_proftab_helper.coverage_pause();
      end if;
    end if;
  end;

  procedure coverage_resume is
  begin
    if get_coverage_type = ut_coverage.gc_block_coverage then
       null;
    else
       ut_proftab_helper.coverage_resume();
    end if;
  end;

  procedure coverage_stop is
  begin
    if not g_develop_mode then
      g_is_started := false;
      if get_coverage_type = ut_coverage.gc_block_coverage then
        $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
         ut_block_coverage_helper.coverage_stop();
        $else
         null;
        $end
      elsif get_coverage_type = ut_coverage.gc_extended_coverage then
        $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
         ut_proftab_helper.coverage_stop();
         ut_block_coverage_helper.coverage_stop();        
        $else
         null;
        $end
      else
         ut_proftab_helper.coverage_stop();
      end if;
    end if;
  end;

  procedure coverage_stop_develop is
  begin
    g_develop_mode := false;
    g_is_started := false;
    if get_coverage_type = ut_coverage.gc_block_coverage then
        $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
         ut_block_coverage_helper.coverage_stop();
        $else
         null;
        $end
    elsif get_coverage_type = ut_coverage.gc_extended_coverage then
        $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
         ut_proftab_helper.coverage_stop();
         ut_block_coverage_helper.coverage_stop();        
        $else
         null;
        $end
    else
       ut_proftab_helper.coverage_stop();
   end if;
  end;

 procedure mock_coverage_id(a_coverage_id integer,a_coverage_type in varchar2) is
  begin
    g_develop_mode := true;
    g_is_started := true;
    g_coverage_id(a_coverage_type) := a_coverage_id;
  end;

  procedure mock_coverage_id(a_coverage_id g_coverage_arr) is
  begin
    g_develop_mode := true;
    g_is_started := true;
    g_coverage_id := a_coverage_id;
  end;
  
  procedure insert_into_tmp_table(a_data t_coverage_sources_tmp_rows) is
  begin
    forall i in 1 .. a_data.count
      insert into ut_coverage_sources_tmp
             (full_name,owner,name,line,text, to_be_skipped)
       values(a_data(i).full_name,a_data(i).owner,a_data(i).name,a_data(i).line,a_data(i).text,a_data(i).to_be_skipped);
  end;

  procedure cleanup_tmp_table is
    pragma autonomous_transaction;
  begin
    null;
    execute immediate 'truncate table ut_coverage_sources_tmp$';
    commit;
  end;

  function is_tmp_table_populated return boolean is
    l_result integer;
  begin
    select 1 into l_result from ut_coverage_sources_tmp where rownum = 1;
    return (l_result = 1);
  exception
    when no_data_found then
      return false;
  end;

  function get_tmp_table_objects_cursor return t_tmp_table_objects_crsr is
    l_result t_tmp_table_objects_crsr;
  begin
    open l_result for
      select o.owner, o.name, o.full_name, max(o.line) lines_count,
             cast(
               collect(decode(to_be_skipped, 'Y', to_char(line))) as ut_varchar2_list
             ) to_be_skipped_list
        from ut_coverage_sources_tmp o
       group by o.owner, o.name, o.full_name;

    return l_result;
  end;

  function get_tmp_table_object_lines(a_owner varchar2, a_object_name varchar2) return ut_varchar2_list is
    l_result ut_varchar2_list;
  begin
    select rtrim(s.text,chr(10)) text
      bulk collect into l_result
      from ut_coverage_sources_tmp s
     where s.owner = a_owner
       and s.name = a_object_name
     order by s.line;

    return l_result;
  end;

end;
/
