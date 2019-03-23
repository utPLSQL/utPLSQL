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
  type t_type_name_map is table of varchar2(128) index by binary_integer;
  g_type_name_map           t_type_name_map;
  g_anytype_name_map        t_type_name_map;

  g_compare_sql_template varchar2(4000) :=
  q'[
    with exp as (
      select 
        ucd.*, 
        {:duplicate_number:} dup_no
      from (
        select 
          ucd.item_data
          ,x.data_id data_id 
          ,position + x.item_no item_no
          {:columns:}
        from {:ut3_owner:}.ut_compound_data_tmp x,
          xmltable('/ROWSET/ROW' passing x.item_data columns
            item_data xmltype path '*'
            ,position for ordinality
            {:xml_to_columns:} ) ucd
          where data_id = :exp_guid
          ) ucd
    )
    , act as (
      select 
        ucd.*,
        {:duplicate_number:} dup_no
      from (
        select 
          ucd.item_data
          ,x.data_id data_id
          ,position + x.item_no item_no 
          {:columns:}
        from {:ut3_owner:}.ut_compound_data_tmp x,
          xmltable('/ROWSET/ROW' passing x.item_data columns 
            item_data xmltype path '*'
            ,position for ordinality
            {:xml_to_columns:} ) ucd
          where data_id = :act_guid
          ) ucd
    )   
    select 
      a.item_data as act_item_data, 
      a.data_id act_data_id,
      e.item_data as exp_item_data, 
      e.data_id exp_data_id,
      {:item_no:} as item_no, 
      nvl(e.dup_no,a.dup_no) dup_no 
    from act a {:join_type:} exp e on ( {:join_condition:} )
    where {:where_condition:}]';

  function get_columns_diff(
    a_expected ut_cursor_column_tab,
    a_actual ut_cursor_column_tab,
    a_order_enforced boolean := false
  ) return tt_column_diffs is
    l_results        tt_column_diffs;
  begin
    execute immediate q'[with
          expected_cols as (
            select access_path exp_column_name,column_position exp_col_pos,
                   replace(column_type,'VARCHAR2','CHAR') exp_col_type_compare, column_type exp_col_type
              from table(:a_expected)
          ),
          actual_cols as (
            select access_path act_column_name,column_position act_col_pos,
                   replace(column_type,'VARCHAR2','CHAR') act_col_type_compare, column_type act_col_type
              from table(:a_actual)),
          joined_cols as (
            select e.*,a.*]'
              || case when a_order_enforced then ',
                   row_number() over(partition by case when a.act_col_pos + e.exp_col_pos is not null then 1 end order by a.act_col_pos) a_pos_nn,
                   row_number() over(partition by case when a.act_col_pos + e.exp_col_pos is not null then 1 end order by e.exp_col_pos) e_pos_nn'
                else
                  null
                end ||q'[
              from expected_cols e
              full outer join actual_cols a
                on e.exp_column_name = a.act_column_name
          )
          select case
                   when exp_col_pos is null and act_col_pos is not null then '+'
                   when exp_col_pos is not null and act_col_pos is null then '-'
                   when exp_col_type_compare != act_col_type_compare then 't'
                   else 'p'
                 end as diff_type,
                 exp_column_name, exp_col_type, exp_col_pos,
                 act_column_name, act_col_type, act_col_pos
            from joined_cols
                 --column is unexpected (extra) or missing
           where act_col_pos is null or exp_col_pos is null
              --column type is not matching (except CHAR/VARCHAR2)
              or act_col_type_compare != exp_col_type_compare]'
              || case when a_order_enforced then q'[
              --column position is not matching (both when excluded extra/missing columns as well as when they are included)
              or (a_pos_nn != e_pos_nn and exp_col_pos != act_col_pos)]'
              else
                null
              end ||q'[
           order by exp_col_pos, act_col_pos]'
      bulk collect into l_results using a_expected, a_actual;
    return l_results;
  end;

  function generate_not_equal_stmt(
    a_data_info ut_cursor_column, a_pk_table ut_varchar2_list
  ) return varchar2
  is
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
      l_sql_stmt := ' (decode(a.'||a_data_info.transformed_name||','||' e.'||a_data_info.transformed_name||',1,0) = 0)';
    end if; 
    return l_sql_stmt;
  end;
   
  function generate_join_by_stmt(
    a_data_info ut_cursor_column, a_pk_table ut_varchar2_list
  ) return varchar2
  is
    l_pk_tab ut_varchar2_list := coalesce(a_pk_table,ut_varchar2_list());
    l_index integer;
    l_sql_stmt varchar2(32767);
  begin 
    if l_pk_tab.count <> 0 then
    l_index:= l_pk_tab.first;
    loop
      if l_pk_tab(l_index) in (a_data_info.access_path, a_data_info.parent_name)  then
        --When then table is nested and join is on whole table
        l_sql_stmt := l_sql_stmt ||' a.'||a_data_info.transformed_name||q'[ = ]'||' e.'||a_data_info.transformed_name;
      end if;
      exit when (a_data_info.access_path = l_pk_tab(l_index)) or l_index = l_pk_tab.count;
      l_index := l_pk_tab.next(l_index);
    end loop;   
    end if;    
    return l_sql_stmt;
  end;
  
  function generate_equal_sql(a_col_name in varchar2) return varchar2 is
  begin
    return ' a.'||a_col_name||q'[ = ]'||' e.'||a_col_name;
  end;

  function generate_partition_stmt(
    a_data_info ut_cursor_column, a_pk_table in ut_varchar2_list, a_alias varchar2 := 'ucd.'
  ) return varchar2
  is
    l_index integer;
    l_sql_stmt varchar2(32767);
  begin    
    if a_pk_table is not empty then
      l_index:= a_pk_table.first;
      loop
        if a_pk_table(l_index) in (a_data_info.access_path, a_data_info.parent_name) then
          --When then table is nested and join is on whole table
          l_sql_stmt := l_sql_stmt ||a_alias||a_data_info.transformed_name;
        end if;        
        exit when (a_data_info.access_path = a_pk_table(l_index)) or l_index = a_pk_table.count;
        l_index := a_pk_table.next(l_index);
      end loop;
    else
      l_sql_stmt := a_alias||a_data_info.transformed_name;
    end if;
    return l_sql_stmt; 
  end;   
  
  function generate_select_stmt(a_data_info ut_cursor_column, a_alias varchar2 := 'ucd.')
  return varchar2
  is
    l_alias varchar2(10) := a_alias;
    l_col_syntax varchar2(4000);
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
  begin    
    if a_data_info.is_sql_diffable = 0 then 
      l_col_syntax :=  l_ut_owner ||'.ut_compound_data_helper.get_hash('||l_alias||a_data_info.transformed_name||'.getClobVal()) as '||a_data_info.transformed_name ;
    elsif a_data_info.is_sql_diffable = 1  and a_data_info.column_type = 'DATE' then
      l_col_syntax :=  'to_date('||l_alias||a_data_info.transformed_name||') as '|| a_data_info.transformed_name;
    elsif  a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('TIMESTAMP') then
      l_col_syntax :=  'to_timestamp('||l_alias||a_data_info.transformed_name||','''||ut_utils.gc_timestamp_format||''') as '|| a_data_info.transformed_name;
    elsif a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('TIMESTAMP WITH TIME ZONE') then
      l_col_syntax :=  'to_timestamp_tz('||l_alias||a_data_info.transformed_name||','''||ut_utils.gc_timestamp_tz_format||''') as '|| a_data_info.transformed_name;
    elsif a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('TIMESTAMP WITH LOCAL TIME ZONE') then
      l_col_syntax :=  ' cast( to_timestamp_tz('||l_alias||a_data_info.transformed_name||','''||ut_utils.gc_timestamp_tz_format||''') AS TIMESTAMP WITH LOCAL TIME ZONE) as '|| a_data_info.transformed_name;
    else
      l_col_syntax :=  l_alias||a_data_info.transformed_name||' as '|| a_data_info.transformed_name;
    end if;       
    return l_col_syntax;
  end;
      
  function generate_xmltab_stmt(a_data_info ut_cursor_column) return varchar2 is
    l_col_type varchar2(4000);
  begin
    if a_data_info.is_sql_diffable = 0 then
      l_col_type := 'XMLTYPE';
    elsif  a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('DATE','TIMESTAMP','TIMESTAMP WITH TIME ZONE',
      'TIMESTAMP WITH LOCAL TIME ZONE') then
      l_col_type := 'VARCHAR2(50)';
    elsif  a_data_info.is_sql_diffable = 1  and a_data_info.column_type in ('INTERVAL DAY TO SECOND','INTERVAL YEAR TO MONTH') then
      l_col_type := a_data_info.column_type;
    else 
      l_col_type := a_data_info.column_type
        ||case when a_data_info.column_len is not null
          then '('||a_data_info.column_len||')'
          else null
          end;
    end if;
    return  a_data_info.transformed_name||' '||l_col_type||q'[ PATH ']'||a_data_info.access_path||q'[']';
  end;
  
  procedure gen_sql_pieces_out_of_cursor(
    a_data_info   ut_cursor_column_tab,
    a_pk_table    ut_varchar2_list,
    a_unordered   boolean,
    a_xml_stmt    out nocopy clob,
    a_select_stmt out nocopy clob,
    a_partition_stmt out nocopy clob,
    a_join_by_stmt out nocopy clob,
    a_not_equal_stmt out nocopy clob
  ) is
    l_partition_tmp clob;
    l_xmltab_list    ut_varchar2_list := ut_varchar2_list();
    l_select_list    ut_varchar2_list := ut_varchar2_list();
    l_partition_list ut_varchar2_list := ut_varchar2_list();
    l_equal_list     ut_varchar2_list := ut_varchar2_list();
    l_join_by_list   ut_varchar2_list := ut_varchar2_list();
    l_not_equal_list ut_varchar2_list := ut_varchar2_list();
    
    procedure add_element_to_list(a_list in out ut_varchar2_list, a_list_element in varchar2)
    is
    begin
      if a_list_element is not null then
        a_list.extend;
        a_list(a_list.last) := a_list_element;
      end if;
    end;
    
  begin
    if a_data_info is not empty then
      for i in 1..a_data_info.count loop
        if a_data_info(i).has_nested_col = 0 then
          --Get XMLTABLE column list
          add_element_to_list(l_xmltab_list,generate_xmltab_stmt(a_data_info(i)));
          --Get Select statment list of columns
          add_element_to_list(l_select_list, generate_select_stmt(a_data_info(i)));
          --Get columns by which we partition
          add_element_to_list(l_partition_list,generate_partition_stmt(a_data_info(i), a_pk_table));
          --Get equal statement
          add_element_to_list(l_equal_list,generate_equal_sql(a_data_info(i).transformed_name));
          --Generate join by stmt
          add_element_to_list(l_join_by_list,generate_join_by_stmt(a_data_info(i), a_pk_table));
          --Generate not equal stmt
          add_element_to_list(l_not_equal_list,generate_not_equal_stmt(a_data_info(i), a_pk_table));
        end if;
      end loop;
      
      a_xml_stmt    := nullif(','||ut_utils.table_to_clob(l_xmltab_list, ' , '),',');
      a_select_stmt := nullif(','||ut_utils.table_to_clob(l_select_list, ' , '),',');
      l_partition_tmp := ut_utils.table_to_clob(l_partition_list, ' , ');
      ut_utils.append_to_clob(a_partition_stmt,' row_number() over (partition by '||l_partition_tmp||' order by '||l_partition_tmp||' ) ');
      
      if a_pk_table.count > 0 then   
        -- If key defined do the join or these and where on diffrences
        a_join_by_stmt := ut_utils.table_to_clob(l_join_by_list, ' and ');
      elsif a_unordered then
        -- If no key defined do the join on all columns
        a_join_by_stmt := ' e.dup_no = a.dup_no and '||ut_utils.table_to_clob(l_equal_list, ' and ');
      else
        -- Else join on rownumber
        a_join_by_stmt := 'a.item_no = e.item_no ';
      end if;
      a_not_equal_stmt := ut_utils.table_to_clob(l_not_equal_list, ' or ');
    else
      --Partition by piece when no data
      ut_utils.append_to_clob(a_partition_stmt,' 1  ');
      a_join_by_stmt := 'a.item_no = e.item_no ';
    end if;
  end;
  
  function gen_compare_sql(
    a_other ut_data_value_refcursor,
    a_join_by_list ut_varchar2_list,
    a_unordered boolean,
    a_inclusion_type boolean,
    a_is_negated boolean
  ) return clob is
    l_compare_sql    clob;    
    l_xmltable_stmt  clob;
    l_select_stmt    clob;
    l_partition_stmt clob;
    l_join_on_stmt   clob;
    l_not_equal_stmt clob;
    l_where_stmt     clob;
    l_ut_owner       varchar2(250) := ut_utils.ut_owner;
     
    function get_join_type(a_inclusion_compare in boolean,a_negated in boolean) return varchar2 is
    begin
     return
       case
         when a_inclusion_compare and not(a_negated) then ' right outer join '
         when a_inclusion_compare and a_negated then ' inner join '
         else ' full outer join '
       end;
    end;
    
    function get_item_no(a_unordered boolean) return varchar2 is
    begin
      return
        case 
          when a_unordered then 'row_number() over ( order by nvl(e.item_no,a.item_no))' 
          else 'nvl(e.item_no,a.item_no) '
        end;
    end;

  begin
    dbms_lob.createtemporary(l_compare_sql, true);   
    --Initiate a SQL template with placeholders
    ut_utils.append_to_clob(l_compare_sql, g_compare_sql_template);
    --Generate a pieceso of dynamic SQL that will substitute placeholders
    gen_sql_pieces_out_of_cursor(
      a_other.cursor_details.cursor_columns_info, a_join_by_list, a_unordered,
      l_xmltable_stmt, l_select_stmt, l_partition_stmt, l_join_on_stmt, 
      l_not_equal_stmt
    );
      
    l_compare_sql := replace(l_compare_sql,'{:duplicate_number:}',l_partition_stmt);
    l_compare_sql := replace(l_compare_sql,'{:columns:}',l_select_stmt);
    l_compare_sql := replace(l_compare_sql,'{:ut3_owner:}',l_ut_owner);
    l_compare_sql := replace(l_compare_sql,'{:xml_to_columns:}',l_xmltable_stmt); 
    l_compare_sql := replace(l_compare_sql,'{:item_no:}',get_item_no(a_unordered));
    l_compare_sql := replace(l_compare_sql,'{:join_type:}',get_join_type(a_inclusion_type,a_is_negated));
    l_compare_sql := replace(l_compare_sql,'{:join_condition:}',l_join_on_stmt);

    if l_not_equal_stmt is not null and ((a_join_by_list.count > 0 and not a_is_negated) or (not a_unordered)) then
        ut_utils.append_to_clob(l_where_stmt,' ( '||l_not_equal_stmt||' ) or ');
    end if;
    --If its inclusion we expect a actual set to fully match and have no extra elements over expected
    if a_inclusion_type then
      ut_utils.append_to_clob(l_where_stmt,case when a_is_negated then ' 1 = 1 ' else ' ( a.data_id is null ) ' end);
    else
      ut_utils.append_to_clob(l_where_stmt,' (a.data_id is null or e.data_id is null) ');
    end if;    
    
    l_compare_sql := replace(l_compare_sql,'{:where_condition:}',l_where_stmt);
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
    a_act_cursor_info ut_cursor_column_tab, a_exp_cursor_info ut_cursor_column_tab,
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_join_by_list ut_varchar2_list, a_unordered boolean, a_enforce_column_order boolean := false,
    a_extract_path varchar2
  ) return tt_row_diffs is
    l_act_extract_xpath  varchar2(32767):= ut_utils.to_xpath(get_column_extract_path(a_act_cursor_info));
    l_exp_extract_xpath  varchar2(32767):= ut_utils.to_xpath(get_column_extract_path(a_exp_cursor_info));
    l_join_xpath     varchar2(32767) := ut_utils.to_xpath(a_join_by_list);
    l_results        tt_row_diffs;
    l_sql            varchar2(32767);
  begin
    l_sql := q'[
    with exp as (
      select
          exp_item_data, exp_data_id, item_no rn, rownum col_no, pk_value,
          s.column_value col, s.column_value.getRootElement() col_name,
          nvl(s.column_value.getclobval(),empty_clob()) col_val
        from (
          select
              exp_data_id, extract( ucd.exp_item_data, :column_path ) exp_item_data, item_no,
              replace( extract( ucd.exp_item_data, :join_by ).getclobval(), chr(10) ) pk_value
            from ut_compound_data_diff_tmp  ucd
           where diff_id = :diff_id
             and ucd.exp_data_id = :self_guid
          ) i,
          table( xmlsequence( extract(i.exp_item_data,:extract_path) ) ) s
    ),
    act as (
      select
          act_item_data, act_data_id, item_no rn, rownum col_no, pk_value,
          s.column_value col, s.column_value.getRootElement() col_name,
          nvl(s.column_value.getclobval(),empty_clob()) col_val
        from (
          select
              act_data_id, extract( ucd.act_item_data, :column_path ) act_item_data, item_no,
              replace( extract( ucd.act_item_data, :join_by ).getclobval(), chr(10) ) pk_value
            from ut_compound_data_diff_tmp  ucd
           where diff_id = :diff_id
             and ucd.act_data_id = :other_guid
          ) i,
          table( xmlsequence( extract(i.act_item_data,:extract_path) ) ) s
    )
    select rn, diff_type, diffed_row, pk_value pk_value
    from (
      select rn, diff_type, diffed_row, pk_value,
             case when diff_type = 'Actual:' then 1 else 2 end rnk,
             1 final_order,
             col_name
      from ( ]'
        || case when a_unordered then q'[
        select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, pk_value, col_name
          from (
            select nvl(exp.rn, act.rn) rn,
                   nvl(exp.pk_value, act.pk_value) pk_value,
                   exp.col exp_item,
                   act.col act_item,
                   nvl(exp.col_name,act.col_name) col_name
              from exp
              join act
                on exp.rn = act.rn and exp.col_name = act.col_name
             where dbms_lob.compare(exp.col_val, act.col_val) != 0
          )
        unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:') ) ]'
        else q'[
        select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, null pk_value, col_name
          from (
            select nvl(exp.rn, act.rn) rn,
                   xmlagg(exp.col order by exp.col_no) exp_item,
                   xmlagg(act.col order by act.col_no) act_item,
                   max(nvl(exp.col_name,act.col_name)) col_name
              from exp exp
              join act act
                on exp.rn = act.rn and exp.col_name = act.col_name
             where dbms_lob.compare(exp.col_val, act.col_val) != 0
             group by (exp.rn, act.rn)
          )
        unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:') ) ]'
        end ||q'[
      )
      union all
      select
          item_no as rn,
          case when exp_data_id is null then 'Extra:' else 'Missing:' end as diff_type,
          xmlserialize(
            content (
              extract( (case when exp_data_id is null then act_item_data else exp_item_data end),'/*/*')
            ) no indent
          ) diffed_row,
          nvl2(
            :join_by,
            replace(
              extract( case when exp_data_id is null then act_item_data else exp_item_data end, :join_by ).getclobval(),
              chr(10)
            ),
            null
          ) pk_value,
          case when exp_data_id is null then 1 else 2 end rnk,
          2 final_order,
          null col_name
        from ut_compound_data_diff_tmp i
       where diff_id = :diff_id
         and act_data_id is null or exp_data_id is null
   )
   order by final_order,]'
    ||case when a_enforce_column_order or (not(a_enforce_column_order) and not(a_unordered)) then
     q'[
         case when final_order = 1 then rn else rnk end,
         case when final_order = 1 then rnk else rn end
     ]'
      when a_unordered then
     q'[
         case when final_order = 1 then col_name else to_char(rnk) end,
         case when final_order = 1 then to_char(rn) else col_name end,
         case when final_order = 1 then to_char(rnk) else col_name end
     ]'
   else
     null
   end;
   execute immediate l_sql
   bulk collect into l_results
    using l_exp_extract_xpath, l_join_xpath, a_diff_id, a_expected_dataset_guid,a_extract_path,
          l_act_extract_xpath, l_join_xpath, a_diff_id, a_actual_dataset_guid,a_extract_path,
          l_join_xpath, l_join_xpath, a_diff_id;    
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
      raise_application_error(ut_utils.gc_dml_for_all,'Failure to insert a diff tmp data.');
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

  function get_compare_cursor(a_diff_cursor_text in clob,a_self_id raw, a_other_id raw) return sys_refcursor is
    l_diff_cursor sys_refcursor;
  begin
    open l_diff_cursor for a_diff_cursor_text using a_self_id, a_other_id;
    return l_diff_cursor;
  end;
  
begin
  g_anytype_name_map(dbms_types.typecode_date)             := 'DATE';
  g_anytype_name_map(dbms_types.typecode_number)           := 'NUMBER';
  g_anytype_name_map(3 /*INTEGER in object type*/)         := 'NUMBER';
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
