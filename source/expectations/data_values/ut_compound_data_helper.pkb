create or replace package body ut_compound_data_helper is
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

  g_diff_count        integer;
  gc_xpath_extract_reg constant varchar2(50) := '^((/ROW/)|^(//)|^(/\*/))?(.*)';
  type t_type_name_map is table of varchar2(128) index by binary_integer;
  g_type_name_map           t_type_name_map;
  g_anytype_name_map        t_type_name_map;

  function get_columns_filter(
    a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_table_alias varchar2 := 'ucd', a_column_alias varchar2 := 'item_data'
  ) return varchar2 is
    l_filter varchar2(32767);
    l_source_column varchar2(500) := a_table_alias||'.'||a_column_alias;
  begin
    -- this SQL statement is constructed in a way that we always get the same number and ordering of substitution variables
    -- That is, we always get: l_exclude_xpath, l_include_xpath
    --   regardless if the variables are NULL (not to be used) or NOT NULL and will be used for filtering
    if a_exclude_xpath is null and a_include_xpath is null then
      l_filter := ':l_exclude_xpath, :l_include_xpath, '||l_source_column||' as '||a_column_alias;
    elsif a_exclude_xpath is not null and a_include_xpath is null then
      l_filter := 'deletexml( '||l_source_column||', :l_exclude_xpath ) as '||a_column_alias||', :l_include_xpath';
    elsif a_exclude_xpath is null and a_include_xpath is not null then
      l_filter := ':l_exclude_xpath, extract( '||l_source_column||', :l_include_xpath ) as '||a_column_alias;
    elsif a_exclude_xpath is not null and a_include_xpath is not null then
      l_filter := 'extract( deletexml( '||l_source_column||', :l_exclude_xpath ), :l_include_xpath ) as '||a_column_alias;
    end if;
    return l_filter;
  end;
    
  function get_columns_diff_ordered(a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab) 
  return tt_column_diffs is
    l_results        tt_column_diffs;
  begin
    with 
      expected_cols as 
      (select access_path exp_column_name,column_position exp_col_pos,
      replace(column_type,'VARCHAR2','CHAR') exp_col_type_compare, column_type exp_col_type
      from table(a_expected)),
      actual_cols as
      (select access_path act_column_name,column_position act_col_pos,
      replace(column_type,'VARCHAR2','CHAR') act_col_type_compare, column_type act_col_type
      from table(a_actual)),
      joined_cols as
      (select e.*,a.*,
        row_number() over(partition by case when a.act_col_pos + e.exp_col_pos is not null then 1 end order by a.act_col_pos) a_pos_nn,
        row_number() over(partition by case when a.act_col_pos + e.exp_col_pos is not null then 1 end order by e.exp_col_pos) e_pos_nn
      from expected_cols e
      full outer join actual_cols a on e.exp_column_name = a.act_column_name)
      select case
               when exp_col_pos is null and act_col_pos is not null then '+'
               when exp_col_pos is not null and act_col_pos is null then '-'
               when exp_col_type_compare != act_col_type_compare then 't'
               else 'p'
             end as diff_type,
             exp_column_name, exp_col_type, exp_col_pos,
             act_column_name, act_col_type, act_col_pos
        bulk collect into l_results
        from joined_cols
             --column is unexpected (extra) or missing
       where act_col_pos is null or exp_col_pos is null
          --column type is not matching (except CHAR/VARCHAR2)
          or act_col_type_compare != exp_col_type_compare
          --column position is not matching (both when excluded extra/missing columns as well as when they are included)
          or (a_pos_nn != e_pos_nn and exp_col_pos != act_col_pos)
       order by exp_col_pos, act_col_pos;
    return l_results;
  end;
  
  function get_columns_diff_unordered(a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab) 
  return tt_column_diffs is
    l_results        tt_column_diffs;
  begin
    with 
      expected_cols as 
      (select access_path exp_column_name,column_position exp_col_pos,
      replace(column_type,'VARCHAR2','CHAR') exp_col_type_compare, column_type exp_col_type
      from table(a_expected)),
      actual_cols as
      (select access_path act_column_name,column_position act_col_pos,
      replace(column_type,'VARCHAR2','CHAR') act_col_type_compare, column_type act_col_type
      from table(a_actual)),
      joined_cols as
      (select e.*,a.*
      from expected_cols e
      full outer join actual_cols a on e.exp_column_name = a.act_column_name)
      select case
               when exp_col_pos is null and act_col_pos is not null then '+'
               when exp_col_pos is not null and act_col_pos is null then '-'
               when exp_col_type_compare != act_col_type_compare then 't'
               else 'p'
             end as diff_type,
             exp_column_name, exp_col_type, exp_col_pos,
             act_column_name, act_col_type, act_col_pos
        bulk collect into l_results
        from joined_cols
             --column is unexpected (extra) or missing
       where act_col_pos is null or exp_col_pos is null
          --column type is not matching (except CHAR/VARCHAR2)
          or act_col_type_compare != exp_col_type_compare
       order by exp_col_pos, act_col_pos;
    return l_results;
  end;

  function get_columns_diff(a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab,a_order_enforced boolean := false) 
  return tt_column_diffs is
  begin
    return
    case
      when a_order_enforced then get_columns_diff_ordered(a_expected,a_actual)
      else get_columns_diff_unordered(a_expected,a_actual)
    end;
  end;
  
  function get_pk_value (a_join_by_xpath varchar2,a_item_data xmltype) return clob is
    l_pk_value clob;
  begin
    select replace((extract(a_item_data,a_join_by_xpath).getclobval()),chr(10)) into l_pk_value from dual;    
    return l_pk_value; 
  end; 
 
  procedure generate_not_equal_stmt(
    a_data_info ut_cursor_column, a_pk_table ut_varchar2_list,
    a_not_equal_stmt in out nocopy clob, a_col_name varchar2
  ) is
    l_pk_tab ut_varchar2_list := coalesce(a_pk_table,ut_varchar2_list());
    l_index integer;
    l_sql_stmt varchar2(32767);
    l_exists boolean := false;
  begin 
    l_index := l_pk_tab.first;
    if l_pk_tab.count > 0 then
      loop
        if a_data_info.access_path = l_pk_tab(l_index) then
          l_exists := true;
        end if;
      exit when l_index = l_pk_tab.count or (a_data_info.access_path = l_pk_tab(l_index));
      l_index := a_pk_table.next(l_index);      
      end loop;
    end if;
    
    if not(l_exists) then  
      l_sql_stmt := l_sql_stmt || case when a_not_equal_stmt is null then null else ' or ' end 
                        ||' (decode(a.'||a_col_name||','||' e.'||a_col_name||',1,0) = 0)';
      ut_utils.append_to_clob(a_not_equal_stmt,l_sql_stmt);
    end if;  
  end;
   
  procedure generate_join_by_stmt(
    a_data_info ut_cursor_column, a_pk_table ut_varchar2_list,
    a_join_by_stmt in out nocopy clob, a_col_name varchar2
  ) is
    l_pk_tab ut_varchar2_list := coalesce(a_pk_table,ut_varchar2_list());
    l_index integer;
    l_sql_stmt varchar2(32767);
  begin 
    if l_pk_tab.count <> 0 then
    l_index:= l_pk_tab.first;
    loop
      if l_pk_tab(l_index) in (a_data_info.access_path, a_data_info.parent_name)  then
        --When then table is nested and join is on whole table
        l_sql_stmt := case when a_join_by_stmt is null then null else ' and ' end;
        l_sql_stmt := l_sql_stmt ||' a.'||a_col_name||q'[ = ]'||' e.'||a_col_name;
      end if;
    exit when (a_data_info.access_path = l_pk_tab(l_index)) or l_index = l_pk_tab.count;
    l_index := l_pk_tab.next(l_index);
    end loop;
    ut_utils.append_to_clob(a_join_by_stmt,l_sql_stmt);
    end if;
  end;
  
  procedure generate_equal_sql(a_equal_stmt in out nocopy clob,a_col_name in varchar2) is  
    l_sql_stmt varchar2(32767);
  begin
    l_sql_stmt := case when a_equal_stmt is null then null else ' and ' end ||' a.'||a_col_name||q'[ = ]'||' e.'||a_col_name;
    ut_utils.append_to_clob(a_equal_stmt,l_sql_stmt);
  end;

  procedure generate_partition_stmt(
    a_data_info ut_cursor_column, a_partition_stmt in out nocopy clob,
    a_pk_table in ut_varchar2_list,a_col_name in varchar2,a_alias varchar2 := 'ucd.'
  ) is
    l_alias varchar2(10) := a_alias;
    l_pk_tab ut_varchar2_list := coalesce(a_pk_table,ut_varchar2_list());
    l_index integer;
    l_sql_stmt varchar2(32767);
  begin    
    if l_pk_tab.count <> 0 then
      l_index:= l_pk_tab.first;
      loop
        if l_pk_tab(l_index) in (a_data_info.access_path, a_data_info.parent_name) then
          --When then table is nested and join is on whole table
          l_sql_stmt := case when a_partition_stmt is null then null else ',' end;
          l_sql_stmt := l_sql_stmt ||l_alias||a_col_name;
        end if;
        
        exit when (a_data_info.access_path = l_pk_tab(l_index)) or l_index = l_pk_tab.count;
        l_index := l_pk_tab.next(l_index);
      end loop;
    else
      l_sql_stmt :=  case when a_partition_stmt is null then null else ',' end ||l_alias||a_col_name;
    end if;
    ut_utils.append_to_clob(a_partition_stmt,l_sql_stmt); 
  end;   
  
  procedure generate_select_stmt(a_data_info ut_cursor_column,a_sql_stmt in out nocopy clob, a_col_name varchar2,a_alias varchar2 := 'ucd.') is
    l_alias varchar2(10) := a_alias;
    l_col_syntax varchar2(4000);
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
  begin    
    if a_data_info.is_sql_diffable = 0 then 
      l_col_syntax :=  l_ut_owner ||'.ut_compound_data_helper.get_hash('||l_alias||a_col_name||'.getClobVal()) as '||a_col_name ;
    else 
      l_col_syntax :=  l_alias||a_col_name||' as '|| a_col_name;
    end if;   
    ut_utils.append_to_clob(a_sql_stmt,','||l_col_syntax);
  end;
      
  procedure generate_xmltab_stmt(a_data_info ut_cursor_column,a_sql_stmt in out nocopy clob, a_col_name varchar2) is
    l_sql_stmt varchar2(32767);
    l_col_type varchar2(4000);
  begin    
    if a_data_info.is_sql_diffable = 0 then 
      l_col_type := 'XMLTYPE';
    elsif a_data_info.is_sql_diffable = 1  and a_data_info.column_type = 'DATE' then 
      l_col_type := 'TIMESTAMP';
    elsif  a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('TIMESTAMP','TIMESTAMP WITH TIME ZONE') then
      l_col_type := a_data_info.column_type;
    --TODO : Oracle bug : https://community.oracle.com/thread/1957521
    elsif a_data_info.is_sql_diffable = 1  and a_data_info.column_type = 'TIMESTAMP WITH LOCAL TIME ZONE' then
      l_col_type := 'VARCHAR2(50)';
    elsif  a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('INTERVAL DAY TO SECOND','INTERVAL YEAR TO MONTH') then
      l_col_type := a_data_info.column_type;
    else 
       l_col_type := a_data_info.column_type||case when a_data_info.column_len is not null then  
         '('||a_data_info.column_len||')' 
       else null end;
    end if;
    l_sql_stmt := case when a_sql_stmt is null then '' else ', ' end ||a_col_name||' '||l_col_type||q'[ PATH ']'||a_data_info.access_path||q'[']';   
    ut_utils.append_to_clob(a_sql_stmt, l_sql_stmt);
  end;
  
  procedure gen_sql_pieces_out_of_cursor(
    a_data_info ut_cursor_column_tab,a_pk_table ut_varchar2_list, a_xml_stmt out nocopy clob,
    a_select_stmt out nocopy clob  ,a_partition_stmt out nocopy clob, a_equal_stmt out nocopy clob, a_join_by_stmt out nocopy clob,
    a_not_equal_stmt out nocopy clob
  ) is
    l_cursor_info ut_cursor_column_tab := a_data_info;
    l_partition_tmp clob;
    l_col_name varchar2(100);
  begin
    if l_cursor_info is not null then  
      --Parition by piece
      ut_utils.append_to_clob(a_partition_stmt,', row_number() over (partition by ');
      for i in 1..l_cursor_info.count loop
        if l_cursor_info(i).has_nested_col = 0 then
        l_col_name := l_cursor_info(i).transformed_name;
         --Get XMLTABLE column list
         generate_xmltab_stmt(l_cursor_info(i),a_xml_stmt,l_col_name);
         --Get Select statment list of columns
         generate_select_stmt(l_cursor_info(i),a_select_stmt,l_col_name);
         --Get columns by which we partition
         generate_partition_stmt(l_cursor_info(i),l_partition_tmp,a_pk_table,l_col_name);
         --Get equal statement
         generate_equal_sql(a_equal_stmt,l_col_name);
         --Generate join by stmt
         generate_join_by_stmt(l_cursor_info(i),a_pk_table,a_join_by_stmt,l_col_name);
         --Generate not equal stmt
         generate_not_equal_stmt(l_cursor_info(i),a_pk_table,a_not_equal_stmt,l_col_name);
         end if;
      end loop;
      --Finish partition by
      ut_utils.append_to_clob(a_partition_stmt,l_partition_tmp||' order by '||l_partition_tmp||' ) dup_no ');    
    else
      --Partition by piece when no data
      ut_utils.append_to_clob(a_partition_stmt,', 1 dup_no ');
    end if;
  end;
  
  procedure get_act_and_exp_set(
    a_current_stmt in out nocopy clob, a_partition_stmt clob, a_select_stmt clob,
    a_xmltable_stmt clob, a_unordered boolean,a_type varchar2
  ) is
    l_temp_string varchar2(32767);
    l_ut_owner       varchar2(250) := ut_utils.ut_owner;
  begin
    ut_utils.append_to_clob(a_current_stmt, a_partition_stmt);
    
    l_temp_string := 'from (select ucd.item_data ';
    ut_utils.append_to_clob(a_current_stmt,l_temp_string);
    ut_utils.append_to_clob(a_current_stmt, a_select_stmt);
     
    l_temp_string := ',x.data_id, '
                     || case when not a_unordered then 'position + x.item_no ' else 'rownum ' end 
                     ||'item_no from ' || l_ut_owner || '.ut_compound_data_tmp x,'
                     ||q'[xmltable('/ROWSET/ROW' passing x.item_data columns ]' ;
    ut_utils.append_to_clob(a_current_stmt,l_temp_string);
    
    ut_utils.append_to_clob(a_current_stmt,a_xmltable_stmt);
    ut_utils.append_to_clob(a_current_stmt,case when a_xmltable_stmt is null then '' else ',' end||q'[ item_data xmltype PATH '*']');
    if not a_unordered then
      ut_utils.append_to_clob(a_current_stmt,', POSITION for ordinality ');
    end if;   
    ut_utils.append_to_clob(a_current_stmt,' ) ucd where data_id = :'||a_type||'_guid ) ucd ) ');  
  end;
    
  
  function gen_compare_sql(
    a_inclusion_type boolean, a_is_negated boolean, a_unordered boolean,
    a_other ut_data_value_refcursor := null, a_join_by_list ut_varchar2_list := ut_varchar2_list()
  ) return clob is
    l_compare_sql   clob;
    l_temp_string   varchar2(32767);
    
    l_xmltable_stmt  clob;
    l_select_stmt    clob;
    l_partition_stmt clob;
    l_equal_stmt     clob;
    l_join_on_stmt   clob;
    l_not_equal_stmt clob;
     
    function get_join_type(a_inclusion_compare in boolean,a_negated in boolean) return varchar2 is
    begin
     return
       case
         when a_inclusion_compare and not(a_negated) then ' right outer join '
         when a_inclusion_compare and a_negated then ' inner join '
         else ' full outer join '
       end;
    end;
  
  begin
    dbms_lob.createtemporary(l_compare_sql, true);
    gen_sql_pieces_out_of_cursor(a_other.cursor_details.cursor_columns_info, a_join_by_list, 
      l_xmltable_stmt, l_select_stmt, l_partition_stmt, l_equal_stmt, 
      l_join_on_stmt, l_not_equal_stmt);
      
    l_temp_string := 'with exp as ( select ucd.* ';    
    ut_utils.append_to_clob(l_compare_sql, l_temp_string);
    get_act_and_exp_set(l_compare_sql, l_partition_stmt,l_select_stmt, l_xmltable_stmt, a_unordered,'exp');
    
        
    l_temp_string :=',act as ( select ucd.* '; 
    ut_utils.append_to_clob(l_compare_sql, l_temp_string);
    get_act_and_exp_set(l_compare_sql, l_partition_stmt,l_select_stmt, l_xmltable_stmt, a_unordered,'act');
    
    l_temp_string :=  ' select a.item_data as act_item_data, a.data_id act_data_id,'
                       ||'e.item_data as exp_item_data, e.data_id exp_data_id, '||
                       case when a_unordered then 'rownum item_no' else 'nvl(e.item_no,a.item_no) item_no' end ||', nvl(e.dup_no,a.dup_no) dup_no '
                       ||'from act a '||get_join_type(a_inclusion_type,a_is_negated)||' exp e on ( ';
    ut_utils.append_to_clob(l_compare_sql,l_temp_string); 
    
    if a_unordered then 
      ut_utils.append_to_clob(l_compare_sql,' e.dup_no = a.dup_no and '); 
    end if;
       
    if (a_join_by_list.count = 0)  and a_unordered then
     -- If no key defined do the join on all columns
     ut_utils.append_to_clob(l_compare_sql,l_equal_stmt);
   elsif (a_join_by_list.count > 0) and a_unordered then
     -- If key defined do the join or these and where on diffrences   
     ut_utils.append_to_clob(l_compare_sql,l_join_on_stmt);         
   elsif not a_unordered then
     ut_utils.append_to_clob(l_compare_sql, 'a.item_no = e.item_no ' );
   end if;   
     
   ut_utils.append_to_clob(l_compare_sql,' ) where ');
   
  if (a_join_by_list.count > 0) and (a_unordered) and (not a_is_negated) then
       if l_not_equal_stmt is not null then
           ut_utils.append_to_clob(l_compare_sql,' ( '||l_not_equal_stmt||' ) or '); 
       end if;
   elsif not a_unordered and l_not_equal_stmt is not null then
     ut_utils.append_to_clob(l_compare_sql,' ( '||l_not_equal_stmt||' ) or ');
   end if;

   --If its inlcusion we expect a actual set to fully match and have no extra elements over expected
   if a_inclusion_type and not(a_is_negated) then
     l_temp_string := ' ( a.data_id is null ) '; 
   elsif a_inclusion_type and a_is_negated then
     l_temp_string := ' 1 = 1 ';
   else
     l_temp_string := ' (a.data_id is null or e.data_id is null) ';
   end if;
   ut_utils.append_to_clob(l_compare_sql,l_temp_string);
   return l_compare_sql;
  end;
  
  function get_column_extract_path(a_cursor_info ut_cursor_column_tab) return ut_varchar2_list is
    l_column_list ut_varchar2_list := ut_varchar2_list();
  begin
    for i in 1..a_cursor_info.count loop
      l_column_list.extend;
      l_column_list(l_column_list.last) := a_cursor_info(i).access_path;
    end loop;
    return l_column_list;
  end;
  
  function get_rows_diff_by_sql(
    a_act_cursor_info ut_cursor_column_tab,a_exp_cursor_info ut_cursor_column_tab,
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_join_by_list ut_varchar2_list, a_unordered boolean, a_enforce_column_order boolean := false
  ) return tt_row_diffs is
    l_act_extract_xpath  varchar2(32767):= ut_utils.to_xpath(get_column_extract_path(a_act_cursor_info));
    l_exp_extract_xpath  varchar2(32767):= ut_utils.to_xpath(get_column_extract_path(a_exp_cursor_info));
    l_join_xpath     varchar2(32767) := ut_utils.to_xpath(a_join_by_list);
    l_results        tt_row_diffs;
    l_sql            varchar2(32767);
  begin
    l_sql := q'[with exp as (
    select exp_item_data, exp_data_id, item_no rn,rownum col_no, pk_value,
      s.column_value col, s.column_value.getRootElement() col_name, s.column_value.getclobval() col_val
    from ( 
      select exp_data_id, extract( ucd.exp_item_data, :column_path ) exp_item_data, item_no,
      ut_compound_data_helper.get_pk_value(:join_by, ucd.exp_item_data) pk_value 
      from ut_compound_data_diff_tmp  ucd
      where diff_id = :diff_id 
      and ucd.exp_data_id = :self_guid) i,
    table( xmlsequence( extract(i.exp_item_data,'/*') ) ) s
    ),
    act as (
    select act_item_data, act_data_id, item_no rn, rownum col_no, pk_value,
      s.column_value col, s.column_value.getRootElement() col_name, s.column_value.getclobval() col_val
    from ( 
      select act_data_id, extract( ucd.act_item_data, :column_path ) act_item_data, item_no,
      ut_compound_data_helper.get_pk_value(:join_by, ucd.act_item_data) pk_value 
      from ut_compound_data_diff_tmp  ucd
      where diff_id = :diff_id 
      and ucd.act_data_id = :other_guid ) i,
    table( xmlsequence( extract(i.act_item_data,'/*') ) ) s
    )
    select rn, diff_type, diffed_row, pk_value pk_value
    from (
      select rn, diff_type, diffed_row, pk_value
      ,case when diff_type = 'Actual:' then 1 else 2 end rnk
      ,1 final_order
      ,col_name
      from ( ]';
      
    if a_unordered then 
      l_sql := l_sql || q'[select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, pk_value,col_name
      from 
        (select nvl(exp.rn, act.rn) rn, nvl(exp.pk_value, act.pk_value) pk_value, exp.col  exp_item, act.col  act_item ,
        nvl(exp.col_name,act.col_name) col_name
        from exp join act on exp.rn = act.rn and exp.col_name = act.col_name
        where dbms_lob.compare(exp.col_val, act.col_val) != 0)
        unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:') 
      ))]';
    else
    l_sql := l_sql || q'[ select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, null pk_value,col_name
      from 
        (select nvl(exp.rn, act.rn) rn,
          xmlagg(exp.col order by exp.col_no) exp_item,
          xmlagg(act.col order by act.col_no) act_item,
          max(nvl(exp.col_name,act.col_name)) col_name
        from exp exp join act act on exp.rn = act.rn and exp.col_name = act.col_name
        where dbms_lob.compare(exp.col_val, act.col_val) != 0
        group by (exp.rn, act.rn)
        )
        unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:'))
      )]';
    end if;
    
    l_sql := l_sql || q'[union all
    select 
      item_no as rn, case when exp_data_id is null then 'Extra:' else 'Missing:' end as diff_type,
      xmlserialize(content (extract((case when exp_data_id is null then act_item_data else exp_item_data end),'/*/*')) no indent) diffed_row,
      nvl2(:join_by,ut_compound_data_helper.get_pk_value(:join_by,case when exp_data_id is null then act_item_data else exp_item_data end),null) pk_value
      ,case when exp_data_id is null then 1 else 2 end rnk
      ,2 final_order
      ,null col_name
    from   ut_compound_data_diff_tmp i
    where  diff_id = :diff_id 
    and    act_data_id is null or exp_data_id is null
   )
   order by final_order,]';
   
   if a_enforce_column_order then
     l_sql := l_sql ||q'[case when final_order = 1 then rn else rnk end,
     case when final_order = 1 then rnk else rn end ]';
   elsif not(a_enforce_column_order) and not(a_unordered) then
     l_sql := l_sql ||q'[case when final_order = 1 then rn else rnk end,
     case when final_order = 1 then rnk else rn end ]';    
   elsif a_unordered then
     l_sql := l_sql ||q'[case when final_order = 1 then col_name else to_char(rnk) end,
     case when final_order = 1 then to_char(rn) else col_name end,
     case when final_order = 1 then to_char(rnk) else col_name end
     ]';  
   end if;

   execute immediate l_sql
   bulk collect into l_results
    using l_exp_extract_xpath,l_join_xpath,a_diff_id, a_expected_dataset_guid,
    l_act_extract_xpath,l_join_xpath,a_diff_id, a_actual_dataset_guid,
    l_join_xpath,l_join_xpath,a_diff_id;
        
    return l_results;
  end;
  
  function get_rows_diff(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2
  ) return tt_row_diffs is
    l_column_filter varchar2(32767);
    l_results       tt_row_diffs;
  begin
    l_column_filter := get_columns_filter(a_exclude_xpath,a_include_xpath);
    execute immediate q'[
      with
        diff_info as ( select item_no 
                       from 
                         (select item_no from ut_compound_data_diff_tmp ucdc where diff_id = :diff_guid order by item_no asc) 
                       where rownum <= :max_rows)
      select *
        from (select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, null pk_value
                from (select nvl(exp.rn, act.rn) rn,
                             xmlagg(exp.col order by exp.col_no) exp_item,
                             xmlagg(act.col order by act.col_no) act_item
                        from (select r.item_no as rn, rownum col_no, s.column_value col,
                                     s.column_value.getRootElement() col_name,
                                     s.column_value.getclobval() col_val
                                from (select ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                                        from ut_compound_data_tmp ucd,
                                        diff_info i
                                       where ucd.data_id = :self_guid
                                       and ucd.item_no = i.item_no
                                    ) r,
                                     table( xmlsequence( extract(r.item_data,'/*/*') ) ) s
                             ) exp
                        join (
                              select item_no as rn, rownum col_no, s.column_value col,
                                     s.column_value.getRootElement() col_name,
                                     s.column_value.getclobval() col_val
                                from (select ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                                        from ut_compound_data_tmp ucd,
                                        diff_info i
                                       where ucd.data_id = :other_guid
                                       and ucd.item_no = i.item_no
                                    ) r,
                                     table( xmlsequence( extract(r.item_data,'/*/*') ) ) s
                              ) act
                          on exp.rn = act.rn and exp.col_name = act.col_name
                       where dbms_lob.compare(exp.col_val, act.col_val) != 0
                       group by exp.rn, act.rn
                     )
              unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:') )
             )
      union all
      select nvl(exp.item_no, act.item_no) rn,
             case when exp.item_no is null then 'Extra:' else 'Missing:' end as diff_type,
             xmlserialize(content nvl(exp.item_data, act.item_data) no indent) diffed_row,
             null pk_value
        from (select ucd.item_no, extract(ucd.item_data,'/*/*') item_data
                from ut_compound_data_tmp ucd
               where ucd.data_id = :self_guid
                 and ucd.item_no in (select i.item_no from diff_info i)
             ) exp
        full outer join (
              select ucd.item_no, extract(ucd.item_data,'/*/*') item_data
                from ut_compound_data_tmp ucd
               where ucd.data_id = :other_guid
                 and ucd.item_no in (select i.item_no from diff_info i)
             )act
          on exp.item_no = act.item_no
       where exp.item_no is null or act.item_no is null
      order by 1, 2]'
    bulk collect into l_results
    using a_diff_id, a_max_rows,
    a_exclude_xpath, a_include_xpath, a_expected_dataset_guid,
    a_exclude_xpath, a_include_xpath, a_actual_dataset_guid,
    a_expected_dataset_guid, a_actual_dataset_guid;
    return l_results;
  end;

  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash is
  begin
    return dbms_crypto.hash(a_data, a_hash_type);
  end;

  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash is
  begin
    return dbms_crypto.hash(a_data, a_hash_type);
  end;

  function get_fixed_size_hash(a_string varchar2, a_base integer :=0,a_size integer := 9999999) return number is
  begin
    return dbms_utility.get_hash_value(a_string,a_base,a_size);
  end;

  procedure insert_diffs_result(a_diff_tab t_diff_tab, a_diff_id raw) is
  begin  
    forall idx in 1..a_diff_tab.count save exceptions
    insert into ut_compound_data_diff_tmp
    ( diff_id, act_item_data, act_data_id, exp_item_data, exp_data_id, item_no, duplicate_no )
    values 
    (a_diff_id, 
    xmlelement( name "ROW", a_diff_tab(idx).act_item_data), a_diff_tab(idx).act_data_id,
    xmlelement( name "ROW", a_diff_tab(idx).exp_item_data), a_diff_tab(idx).exp_data_id,
    a_diff_tab(idx).item_no, a_diff_tab(idx).dup_no);
  exception
    when ut_utils.ex_failure_for_all then
      raise_application_error(ut_utils.gc_failure_for_all,'Failure to insert a diff tmp data.');
  end;
  
  procedure set_rows_diff(a_rows_diff integer) is
  begin
    g_diff_count := a_rows_diff;
  end;
  
  procedure cleanup_diff is
  begin
    g_diff_count := 0;
  end;
  
  function get_rows_diff_count return integer is
  begin
    return g_diff_count;
  end;

  --Filter out columns from cursor based on include (exists) or exclude (not exists)
  function filter_out_cols(
    a_cursor_info ut_cursor_column_tab,
    a_current_list ut_varchar2_list,
    a_include boolean := true
  ) return ut_cursor_column_tab is
    l_result ut_cursor_column_tab := ut_cursor_column_tab();
    l_filter_sql varchar2(32767);
  begin 
   l_filter_sql :=
   q'[with 
   coltab as (
     select i.parent_name,i.access_path,i.has_nested_col,i.transformed_name,i.hierarchy_level,i.column_position ,
     i.xml_valid_name,i.column_name,i.column_type,i.column_type_name ,i.column_schema,i.column_len,i.is_sql_diffable ,i.is_collection
     from table(:cursor_info) i),
   filter as (select column_value from table(:current_list))
   select ut_cursor_column(i.parent_name,i.access_path,i.has_nested_col,i.transformed_name,i.hierarchy_level,i.column_position ,
     i.xml_valid_name,i.column_name,i.column_type,i.column_type_name ,i.column_schema,i.column_len,i.is_sql_diffable ,i.is_collection)
   from coltab i where ]'||case when a_include then null else ' not ' end 
   ||q'[exists (select 1 from filter f where regexp_like(i.access_path, '^'||f.column_value||'($|/.*)'))]';
     
   execute immediate l_filter_sql bulk collect into l_result using a_cursor_info,a_current_list;
   return l_result;
  end;
 
  function get_missing_filter_columns(a_cursor_info ut_cursor_column_tab, a_column_filter_list ut_varchar2_list)
  return ut_varchar2_list is
    l_result ut_varchar2_list := ut_varchar2_list();
  begin 
   select fl.column_value
   bulk collect into l_result
   from table(a_column_filter_list) fl
   where not exists (select 1 from table(a_cursor_info) c where regexp_like(c.access_path, '^'||fl.column_value||'($|/.*)')); 
   return l_result;
  end;
 
  function get_missing_pk(a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab, a_current_list ut_varchar2_list) 
  return tt_missing_pk is
    l_actual ut_varchar2_list := coalesce(get_missing_filter_columns(a_actual,a_current_list),ut_varchar2_list());
    l_expected  ut_varchar2_list := coalesce(get_missing_filter_columns(a_expected,a_current_list),ut_varchar2_list());
    l_missing_pk tt_missing_pk;
  begin 
    select name,type
    bulk collect into l_missing_pk
    from
    (select act.column_value name, 'e' type from table(l_expected) act    
    union all
    select exp.column_value name, 'a' type from table(l_actual) exp)
    order by type desc,name;
    return l_missing_pk;
  end;
  
  function inc_exc_columns_from_cursor (a_cursor_info ut_cursor_column_tab, a_exclude_xpath ut_varchar2_list, a_include_xpath ut_varchar2_list)
  return ut_cursor_column_tab is
    l_filtered_set ut_varchar2_list := ut_varchar2_list();
    l_result ut_cursor_column_tab := ut_cursor_column_tab();
    l_include boolean;
  begin
    -- if include and exclude is not null its columns from include minus exclude
    -- If include is not null and exclude is null cursor will have only include
    -- If exclude is not null and include is null cursor will have all except exclude
    if a_include_xpath.count > 0 and a_exclude_xpath.count > 0 then
      select col_names bulk collect into l_filtered_set
      from(
        select regexp_replace(column_value,gc_xpath_extract_reg,'\5') col_names
        from table(a_include_xpath)
        minus
        select regexp_replace(column_value,gc_xpath_extract_reg,'\5') col_names
        from table(a_exclude_xpath)
       );
       l_include := true;
    elsif a_include_xpath.count > 0 and a_exclude_xpath.count = 0 then
      select regexp_replace(column_value,gc_xpath_extract_reg,'\5') col_names
      bulk collect into l_filtered_set
      from table(a_include_xpath);
      l_include := true;
    elsif a_include_xpath.count = 0 and a_exclude_xpath.count > 0 then
      select regexp_replace(column_value,gc_xpath_extract_reg,'\5') col_names
      bulk collect into l_filtered_set
      from table(a_exclude_xpath);
      l_include := false;
    elsif a_cursor_info is not null then
      l_result:= a_cursor_info;
    else
      l_result := ut_cursor_column_tab();
    end if;
    
    if l_filtered_set.count > 0 then
      l_result := filter_out_cols(a_cursor_info,l_filtered_set,l_include);
    end if;      

    return l_result;
  end;
  
  function contains_collection (a_cursor_info ut_cursor_column_tab)
  return number is
    l_collection_elements number;
  begin
    select count(1) into l_collection_elements from
    table(a_cursor_info) c where c.is_collection = 1;
    return l_collection_elements;
  end;
  
  function remove_incomparable_cols( a_cursor_details ut_cursor_column_tab,a_incomparable_cols ut_varchar2_list)
  return ut_cursor_column_tab is
    l_result ut_cursor_column_tab;
  begin
    select ut_cursor_column(i.parent_name,i.access_path,i.has_nested_col,i.transformed_name,i.hierarchy_level,i.column_position ,
    i.xml_valid_name,i.column_name,i.column_type,i.column_type_name ,i.column_schema,i.column_len,i.is_sql_diffable ,i.is_collection)
    bulk collect into l_result
    from table(a_cursor_details) i
    left outer join table(a_incomparable_cols) c
    on (i.access_path = c.column_value)
    where c.column_value is null;  

    return l_result;
  end;
 
  function getxmlchildren(a_parent_name varchar2,a_cursor_table ut_cursor_column_tab)
  return xmltype is
    l_result xmltype;
  begin
    select xmlagg(xmlelement(evalname t.column_name,t.column_type,
                                      getxmlchildren(t.column_name,a_cursor_table)))
    into l_result
    from table(a_cursor_table) t
    where (a_parent_name is not null and parent_name = a_parent_name and hierarchy_level > 1 and column_name is not null)
      or (a_parent_name is null and parent_name is null and hierarchy_level = 1 and column_name is not null)
    having count(*) > 0;

    return l_result;
  end;

  function is_sql_compare_allowed(a_type_name varchar2)
  return boolean is
    l_assert boolean;
  begin
    --clob/blob/xmltype/object/nestedcursor/nestedtable
    if a_type_name IN (g_type_name_map(dbms_sql.blob_type),
                       g_type_name_map(dbms_sql.clob_type),
                       g_type_name_map(dbms_sql.bfile_type),
                       g_anytype_name_map(dbms_types.typecode_namedcollection))
    then    
      l_assert := false;
    else
      l_assert := true;
    end if;
    return l_assert;
  end;

  function get_column_type_desc(a_type_code in integer, a_dbms_sql_desc in boolean)
  return varchar2 is
  begin
   return
     case
       when a_dbms_sql_desc then g_type_name_map(a_type_code)
       else g_anytype_name_map(a_type_code)
     end;
  end;

  function get_anytype_members_info( a_anytype anytype )
  return t_anytype_members_rec is
    l_result  t_anytype_members_rec;
  begin
    if a_anytype is not null then
      l_result.type_code := a_anytype.getinfo(
        prec        => l_result.precision,
        scale       => l_result.scale,
        len         => l_result.length,
        csid        => l_result.char_set_id,
        csfrm       => l_result.char_set_frm,
        schema_name => l_result.schema_name,
        type_name   => l_result.type_name,
        version     => l_result.version,
        numelems    => l_result.elements_count
      );
    end if;
    return l_result;
  end;

  function get_attr_elem_info( a_anytype anytype, a_pos pls_integer := null )
  return t_anytype_elem_info_rec is
    l_result  t_anytype_elem_info_rec;
  begin
    if a_anytype is not null then
      l_result.type_code := a_anytype.getattreleminfo(
        pos           => a_pos,
        prec          => l_result.precision,
        scale         => l_result.scale,
        len           => l_result.length,
        csid          => l_result.char_set_id,
        csfrm         => l_result.char_set_frm,
        attr_elt_type => l_result.attr_elt_type,
        aname         => l_result.attribute_name
      );
    end if;
    return l_result;
  end;

begin
  g_anytype_name_map(dbms_types.typecode_date)             := 'DATE';
  g_anytype_name_map(dbms_types.typecode_number)           := 'NUMBER';
  g_anytype_name_map(dbms_types.typecode_raw)              := 'RAW';
  g_anytype_name_map(dbms_types.typecode_char)             := 'CHAR';
  g_anytype_name_map(dbms_types.typecode_varchar2)         := 'VARCHAR2';
  g_anytype_name_map(dbms_types.typecode_varchar)          := 'VARCHAR';
  g_anytype_name_map(dbms_types.typecode_blob)             := 'BLOB';
  g_anytype_name_map(dbms_types.typecode_bfile)            := 'BFILE';
  g_anytype_name_map(dbms_types.typecode_clob)             := 'CLOB';
  g_anytype_name_map(dbms_types.typecode_timestamp)        := 'TIMESTAMP';
  g_anytype_name_map(dbms_types.typecode_timestamp_tz)     := 'TIMESTAMP WITH TIME ZONE';
  g_anytype_name_map(dbms_types.typecode_timestamp_ltz)    := 'TIMESTAMP WITH LOCAL TIME ZONE';
  g_anytype_name_map(dbms_types.typecode_interval_ym)      := 'INTERVAL YEAR TO MONTH';
  g_anytype_name_map(dbms_types.typecode_interval_ds)      := 'INTERVAL DAY TO SECOND';
  g_anytype_name_map(dbms_types.typecode_bfloat)           := 'BINARY_FLOAT';
  g_anytype_name_map(dbms_types.typecode_bdouble)          := 'BINARY_DOUBLE';
  g_anytype_name_map(dbms_types.typecode_urowid)           := 'UROWID';
  g_anytype_name_map(dbms_types.typecode_varray)           := 'VARRRAY';
  g_anytype_name_map(dbms_types.typecode_table)            := 'TABLE';
  g_anytype_name_map(dbms_types.typecode_namedcollection)  := 'NAMEDCOLLECTION';  
  g_anytype_name_map(dbms_types.typecode_object)           := 'OBJECT';
 
  g_type_name_map( dbms_sql.binary_bouble_type )           := 'BINARY_DOUBLE';
  g_type_name_map( dbms_sql.bfile_type )                   := 'BFILE';
  g_type_name_map( dbms_sql.binary_float_type )            := 'BINARY_FLOAT';
  g_type_name_map( dbms_sql.blob_type )                    := 'BLOB';
  g_type_name_map( dbms_sql.long_raw_type )                := 'LONG RAW';
  g_type_name_map( dbms_sql.char_type )                    := 'CHAR';
  g_type_name_map( dbms_sql.clob_type )                    := 'CLOB';
  g_type_name_map( dbms_sql.long_type )                    := 'LONG';
  g_type_name_map( dbms_sql.date_type )                    := 'DATE';
  g_type_name_map( dbms_sql.interval_day_to_second_type )  := 'INTERVAL DAY TO SECOND';
  g_type_name_map( dbms_sql.interval_year_to_month_type )  := 'INTERVAL YEAR TO MONTH';
  g_type_name_map( dbms_sql.raw_type )                     := 'RAW';
  g_type_name_map( dbms_sql.timestamp_type )               := 'TIMESTAMP';
  g_type_name_map( dbms_sql.timestamp_with_tz_type )       := 'TIMESTAMP WITH TIME ZONE';
  g_type_name_map( dbms_sql.timestamp_with_local_tz_type ) := 'TIMESTAMP WITH LOCAL TIME ZONE';
  g_type_name_map( dbms_sql.varchar2_type )                := 'VARCHAR2';
  g_type_name_map( dbms_sql.number_type )                  := 'NUMBER';
  g_type_name_map( dbms_sql.rowid_type )                   := 'ROWID';
  g_type_name_map( dbms_sql.urowid_type )                  := 'UROWID';  
  g_type_name_map( dbms_sql.user_defined_type )            := 'USER_DEFINED_TYPE';
  g_type_name_map( dbms_sql.ref_type )                     := 'REF_TYPE';
  
end;
/
