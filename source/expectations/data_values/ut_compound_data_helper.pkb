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

  g_user_defined_type pls_integer := dbms_sql.user_defined_type;
  g_diff_count        integer;
  g_filter_tab        ut_varchar2_list;
  
  function get_column_info_xml(a_column_details ut_key_anyval_pair) return xmltype is
    l_result varchar2(4000);
    l_res xmltype;
    l_data ut_data_value := a_column_details.value;
    l_key varchar2(4000) := ut_utils.xmlgen_escaped_string(a_column_details.KEY);
    l_is_diff number;
  begin   
    l_result := '<'||l_key||' xml_valid_name="'||l_key;
    if l_data is of(ut_data_value_xmltype) then
      l_result := l_result||'" sql_diffable="0">' ||trim( both '''' from (treat(l_data as ut_data_value_xmltype).to_string));
    else
      l_is_diff := ut_curr_usr_compound_helper.is_sql_compare_int((treat(l_data as ut_data_value_varchar2).data_value));
      l_result := l_result||'" sql_diffable="'||l_is_diff||'">' || ut_utils.xmlgen_escaped_string((treat(l_data as ut_data_value_varchar2).data_value));
    end if;
    l_result := l_result ||'</'||l_key||'>'; 
    return xmltype(l_result);
  end;
  
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
 
  /**
  * Current get column filter shaving off ROW tag during extract, this not working well with include and XMLTABLE option
  * so when there is extract we artificially inject removed tag
  **/
  function get_columns_row_filter(
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
      l_filter := ':l_exclude_xpath, xmlelement("ROW",extract( '||l_source_column||', :l_include_xpath )) as '||a_column_alias;
    elsif a_exclude_xpath is not null and a_include_xpath is not null then
      l_filter := 'xmlelement("ROW",extract( deletexml( '||l_source_column||', :l_exclude_xpath ), :l_include_xpath )) as '||a_column_alias;
    end if;
    return l_filter;
  end;

  function get_columns_diff(
    a_expected xmltype, a_actual xmltype, a_exclude_xpath varchar2, a_include_xpath varchar2
  ) return tt_column_diffs is
    l_column_filter  varchar2(32767);
    l_sql            varchar2(32767);
    l_results        tt_column_diffs;
  begin
    l_column_filter := get_columns_row_filter(a_exclude_xpath, a_include_xpath);
    --CARDINALITY hints added to address issue: https://github.com/utPLSQL/utPLSQL/issues/752
    l_sql := q'[
      with
        expected_cols as ( select :a_expected as item_data from dual ),
        actual_cols as ( select :a_actual as item_data from dual ),
        expected_cols_info as (
          select e.*,
                 replace(expected_type,'VARCHAR2','CHAR') expected_type_compare
            from (
                  select /*+ CARDINALITY(xt 100) */
                         rownum expected_pos,
                         xt.name expected_name,
                         xt.type expected_type
                    from (select ]'||l_column_filter||q'[ from expected_cols ucd) x,
                         xmltable(
                           '/ROW/*'
                           passing x.item_data
                           columns
                             name     varchar2(4000)  PATH '@xml_valid_name',
                             type     varchar2(4000) PATH '/'
                         ) xt
                 ) e
        ),
        actual_cols_info as (
          select a.*,
                 replace(actual_type,'VARCHAR2','CHAR') actual_type_compare
            from (select /*+ CARDINALITY(xt 100) */
                         rownum actual_pos,
                         xt.name actual_name,
                         xt.type actual_type
                    from (select ]'||l_column_filter||q'[ from actual_cols ucd) x,
                         xmltable('/ROW/*'
                           passing x.item_data
                           columns
                             name     varchar2(4000)  path '@xml_valid_name',
                             type      varchar2(4000) path '/'
                         ) xt
                 ) a
        ),
        joined_cols as (
         select e.*, a.*,
                row_number() over(partition by case when actual_pos + expected_pos is not null then 1 end order by actual_pos) a_pos_nn,
                row_number() over(partition by case when actual_pos + expected_pos is not null then 1 end order by expected_pos) e_pos_nn
           from expected_cols_info e
           full outer join actual_cols_info a on e.expected_name = a.actual_name
      )
      select case
               when expected_pos is null and actual_pos is not null then '+'
               when expected_pos is not null and actual_pos is null then '-'
               when expected_type_compare != actual_type_compare then 't'
               else 'p'
             end as diff_type,
             expected_name, expected_type, expected_pos,
             actual_name, actual_type, actual_pos
        from joined_cols
             --column is unexpected (extra) or missing
       where actual_pos is null or expected_pos is null
          --column type is not matching (except CHAR/VARCHAR2)
          or actual_type_compare != expected_type_compare
          --column position is not matching (both when excluded extra/missing columns as well as when they are included)
          or (a_pos_nn != e_pos_nn and expected_pos != actual_pos)
       order by expected_pos, actual_pos]';
    execute immediate l_sql
      bulk collect into l_results
      using a_expected, a_actual, a_exclude_xpath, a_include_xpath, a_exclude_xpath, a_include_xpath;

    return l_results;
  end;
  
  function get_pk_value (a_join_by_xpath varchar2,a_item_data xmltype) return clob is
    l_pk_value clob;
  begin
    select replace((extract(a_item_data,a_join_by_xpath).getclobval()),chr(10)) into l_pk_value from dual;    
    return l_pk_value; 
  end;

  function get_rows_diff_by_sql(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_join_by_xpath varchar2, a_unordered boolean
  ) return tt_row_diffs is
    
    l_act_col_filter varchar2(32767);
    l_exp_col_filter varchar2(32767);
    l_results       tt_row_diffs;
    l_sql           varchar2(32767);
  begin
    l_act_col_filter := get_columns_row_filter(a_exclude_xpath,a_include_xpath,'ucd','act_item_data');
    l_exp_col_filter := get_columns_row_filter(a_exclude_xpath,a_include_xpath,'ucd','exp_item_data');
    
    --TODO: Generate SQL based on input as unorder join should aggregate
    
   l_sql := q'[with exp as (
    select exp_item_data, exp_data_id, item_no rn,rownum col_no,
      nvl2(exp_item_data,ut3.ut_compound_data_helper.get_pk_value(i.join_by,exp_item_data),null) pk_value,
      s.column_value col, s.column_value.getRootElement() col_name, s.column_value.getclobval() col_val
    from ( 
      select exp_data_id, ]'||l_exp_col_filter||q'[, :join_by join_by, item_no
      from ut_compound_data_diff_tmp  ucd
      where diff_id = :diff_id 
      and ucd.exp_data_id = :self_guid) i,
    table( xmlsequence( extract(i.exp_item_data,'/*/*') ) ) s
    ),
    act as (
    select act_item_data, act_data_id, item_no rn, rownum col_no,
      nvl2(act_item_data,ut3.ut_compound_data_helper.get_pk_value(i.join_by,act_item_data),null) pk_value,
      s.column_value col, s.column_value.getRootElement() col_name, s.column_value.getclobval() col_val
    from ( 
      select act_data_id, ]'||l_act_col_filter||q'[, :join_by join_by, item_no
      from ut_compound_data_diff_tmp  ucd
      where diff_id = :diff_id 
      and ucd.act_data_id = :other_guid ) i,
    table( xmlsequence( extract(i.act_item_data,'/*/*') ) ) s
    )
    select rn, diff_type, diffed_row, pk_value pk_value
    from (
      select rn, diff_type, diffed_row, pk_value
      ,case when diff_type = 'Actual:' then 1 else 2 end rnk
      ,1 final_order
      from ( ]';
      
    if a_unordered then 
      l_sql := l_sql || q'[select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, pk_value pk_value
      from 
        (select nvl(exp.rn, act.rn) rn, nvl(exp.pk_value, act.pk_value) pk_value, exp.col  exp_item, act.col  act_item       
        from exp join act on exp.rn = act.rn and exp.col_name = act.col_name
        where dbms_lob.compare(exp.col_val, act.col_val) != 0)
        unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:') 
      ))]';
    else
    l_sql := l_sql || q'[ select rn, diff_type, xmlserialize(content data_item no indent) diffed_row, null pk_value
      from 
        (select nvl(exp.rn, act.rn) rn,
          xmlagg(exp.col order by exp.col_no) exp_item,
          xmlagg(act.col order by act.col_no) act_item
        from exp exp join act act on exp.rn = act.rn and exp.col_name = act.col_name
        where dbms_lob.compare(exp.col_val, act.col_val) != 0
        group by exp.rn, act.rn
        )
        unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:'))
      )]';
    end if;
    
    l_sql := l_sql || q'[union all
    select 
      item_no as rn, case when exp_data_id is null then 'Extra:' else 'Missing:' end as diff_type,
      xmlserialize(content (extract((case when exp_data_id is null then act_item_data else exp_item_data end),'/*/*')) no indent) diffed_row,
      nvl2(:join_by,ut3.ut_compound_data_helper.get_pk_value(:join_by,case when exp_data_id is null then act_item_data else exp_item_data end),null) pk_value
      ,case when exp_data_id is null then 1 else 2 end rnk
      ,2 final_order
    from   ut_compound_data_diff_tmp i
    where  diff_id = :diff_id 
    and    act_data_id is null or exp_data_id is null
   )
   order by final_order, 
   case when final_order = 1 then rn else rnk end,
   case when final_order = 1 then rnk else rn end ]';
   
   execute immediate l_sql
   bulk collect into l_results
    using a_exclude_xpath, a_include_xpath, a_join_by_xpath,
          a_diff_id, a_expected_dataset_guid,
          a_exclude_xpath,a_include_xpath, a_join_by_xpath,
          a_diff_id, a_actual_dataset_guid,
          a_join_by_xpath,a_join_by_xpath, a_diff_id;
        
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

  function get_rows_diff(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_join_by_xpath varchar2,a_refcursor boolean, a_unordered boolean
  ) return tt_row_diffs is
    l_result tt_row_diffs := tt_row_diffs();
  begin
    case 
      when a_refcursor then
        l_result := get_rows_diff_by_sql(a_expected_dataset_guid, a_actual_dataset_guid, a_diff_id,
                                   a_max_rows, a_exclude_xpath, a_include_xpath ,a_join_by_xpath, a_unordered);                                  
      else
        l_result := get_rows_diff(a_expected_dataset_guid, a_actual_dataset_guid, a_diff_id,
                                   a_max_rows, a_exclude_xpath, a_include_xpath);
      end case;
      return l_result;
  end;

  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash is
  begin
    return dbms_crypto.hash(a_data, a_hash_type);
  end;

  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash is
  begin
    return dbms_crypto.hash(a_data, a_hash_type);
  end;

  function columns_hash(
    a_data_value_cursor ut_data_value_refcursor, a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_hash_type binary_integer := dbms_crypto.hash_sh1
  ) return t_hash is
    l_cols_hash t_hash;
  begin      
    if not a_data_value_cursor.is_null then      
      execute immediate
      q'[select dbms_crypto.hash(replace(x.item_data.getclobval(),'>CHAR<','>VARCHAR2<'),]'||a_hash_type||') ' ||
      '  from ( select '||get_columns_filter(a_exclude_xpath, a_include_xpath)||
      '           from (select :columns_info as item_data from dual ) ucd' ||
      '  ) x'
      into l_cols_hash using a_exclude_xpath,a_include_xpath, a_data_value_cursor.columns_info;
    end if;
    return l_cols_hash;
  end;

  function is_pk_exists(a_expected_cursor xmltype,a_actual_cursor xmltype, a_exclude_xpath varchar2, a_include_xpath varchar2,a_join_by_xpath varchar2) 
  return tt_missing_pk is
    l_pk_xpath_tabs ut_varchar2_list := ut_varchar2_list();
    l_column_filter  varchar2(32767);
    l_no_missing_keys tt_missing_pk := tt_missing_pk();

  begin
    if a_join_by_xpath is not null then
      l_pk_xpath_tabs := ut_utils.string_to_table(a_join_by_xpath,'|');
      l_column_filter := get_columns_row_filter(a_exclude_xpath, a_include_xpath);
          
      execute immediate q'[
      with  xpaths_tab as (select column_value  xpath from table(:xpath_tabs)),
        expected_column_info as ( select :expected as item_data from dual ),
        actual_column_info as ( select :actual as item_data from dual ) 
        select  REGEXP_SUBSTR (xpath,'[^(/\*/)](.+)$'),diif_type from
        (
         (select xpath,'e' diif_type from xpaths_tab
         minus
         select xpath,'e' diif_type
         from   ( select ]'||l_column_filter||q'[ from expected_column_info ucd) x
         ,xpaths_tab
         where xmlexists (xpaths_tab.xpath passing x.item_data)
         )
         union all
         (select xpath,'a' diif_type from xpaths_tab
         minus
         select xpath,'a' diif_type
         from   ( select ]'||l_column_filter||q'[ from actual_column_info ucd) x
         ,xpaths_tab
         where xmlexists (xpaths_tab.xpath passing x.item_data)
         )       
         )]' bulk collect into l_no_missing_keys 
         using l_pk_xpath_tabs,a_expected_cursor,a_actual_cursor,
         a_exclude_xpath, a_include_xpath,
         a_exclude_xpath, a_include_xpath; 
    
    end if;
    
    return l_no_missing_keys;
  end;
        
  procedure generate_not_equal_stmt(a_data_info ut_cursor_column, a_pk_table ut_varchar2_list, a_not_equal_stmt in out nocopy clob,
    a_col_name varchar2) is
    l_pk_tab ut_varchar2_list := coalesce(a_pk_table,ut_varchar2_list());
    l_index integer;
    l_sql_stmt varchar2(32767);
    l_exists boolean := false;
  begin 
    l_index := l_pk_tab.first;
    if l_pk_tab.count > 0 then
      loop
        if a_data_info.column_name = l_pk_tab(l_index) then
          l_exists := true;
        end if;
      exit when l_index = l_pk_tab.count or (a_data_info.column_name = l_pk_tab(l_index));
      l_index := a_pk_table.next(l_index);      
      end loop;
    end if;
    
    if not(l_exists) then  
      l_sql_stmt := l_sql_stmt || case when a_not_equal_stmt is null then null else ' or ' end 
                        ||' (decode(a.'||a_col_name||','||' e.'||a_col_name||',1,0) = 0)';
      ut_utils.append_to_clob(a_not_equal_stmt,l_sql_stmt);
    end if;  
  end;
   
  procedure generate_join_by_stmt(a_data_info ut_cursor_column, a_pk_table ut_varchar2_list, a_join_by_stmt in out nocopy clob,
    a_col_name varchar2) is
    l_pk_tab ut_varchar2_list := coalesce(a_pk_table,ut_varchar2_list());
    l_index integer;
    l_sql_stmt varchar2(32767);
  begin 
    if l_pk_tab.count <> 0 then
    l_index:= l_pk_tab.first;
    loop
      if a_data_info.column_name = a_pk_table(l_index) then
        l_sql_stmt := l_sql_stmt || case when a_join_by_stmt is null then null else ' and ' end;  
        l_sql_stmt := l_sql_stmt ||' a.'||a_col_name||q'[ = ]'||' e.'||a_col_name;
       end if;
    exit when (a_data_info.column_name = a_pk_table(l_index)) or l_index = a_pk_table.count;
    l_index := a_pk_table.next(l_index);
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

  procedure generate_partition_stmt(a_partition_stmt in out nocopy clob,a_col_name in varchar2) is  
    l_alias varchar2(10) := 'ucd.';
  begin    
    ut_utils.append_to_clob(a_partition_stmt,case when a_partition_stmt is null then null else ',' end||l_alias||a_col_name); 
  end;   
  
  procedure generate_select_stmt(a_data_info ut_cursor_column,a_sql_stmt in out nocopy clob, a_col_name varchar2) is
    l_sql_stmt clob;
    l_alias varchar2(10) := 'ucd.';
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
    else 
       l_col_type := a_data_info.column_type||'('||a_data_info.column_len||')';
    end if;
    l_sql_stmt := ' '||a_col_name||' '||l_col_type||q'[ PATH ']'||a_data_info.access_path||q'[',]';   
    ut_utils.append_to_clob(a_sql_stmt, l_sql_stmt);
  end;
  
  procedure gen_sql_pieces_out_of_cursor(a_data_info ut_data_value_refcursor,a_pk_table ut_varchar2_list, a_xml_stmt out nocopy clob, 
  a_select_stmt out nocopy clob  ,a_partition_stmt out nocopy clob, a_equal_stmt out nocopy clob, a_join_by_stmt out nocopy clob,
  a_not_equal_stmt out nocopy clob) is
    l_cursor_info ut_cursor_column_tab := a_data_info.cursor_details.cursor_info;
    l_partition_tmp clob;
    l_col_name varchar2(30);
  begin
    if l_cursor_info is not null then  
      --Parition by piece 
      ut_utils.append_to_clob(a_partition_stmt,', row_number() over (partition by ');
      --TODO : Handle nested objects...
      for i in 1..l_cursor_info.count loop
        l_col_name := case when l_cursor_info(i).parent_name is null then 
                         l_cursor_info(i).xml_valid_name
                        else 
                          utl_raw.cast_to_varchar2(l_cursor_info(i).nested_name)
                        end;
         --Get XMLTABLE column list
         generate_xmltab_stmt(l_cursor_info(i),a_xml_stmt,l_col_name);
         --Get Select statment list of columns
         generate_select_stmt(l_cursor_info(i),a_select_stmt,l_col_name);
         --Get columns by which we partition
         generate_partition_stmt(l_partition_tmp,l_col_name);
         --Get equal statement
         generate_equal_sql(a_equal_stmt,l_col_name);
         --Generate join by stmt
         generate_join_by_stmt(l_cursor_info(i),a_pk_table,a_join_by_stmt,l_col_name);
         --Generate not equal stmt
         generate_not_equal_stmt(l_cursor_info(i),a_pk_table,a_not_equal_stmt,l_col_name);
      end loop;
      --Finish parition by 
      ut_utils.append_to_clob(a_partition_stmt,l_partition_tmp||' order by '||l_partition_tmp||' ) dup_no ');    
    else
      --Partition by piece when no data
      ut_utils.append_to_clob(a_partition_stmt,', 1 dup_no ');
    end if;
  end;
  
  function gen_compare_sql(a_column_info xmltype, a_exclude_xpath varchar2, a_include_xpath varchar2, 
                           a_join_by_xpath varchar2, a_inclusion_type boolean, a_is_negated boolean,
                           a_unordered boolean, a_other ut_data_value_refcursor :=null, a_join_by_list ut_varchar2_list:=null ) return clob is
    l_compare_sql   clob;
    l_temp_string   varchar2(32767);
    
    l_ut_owner       varchar2(250) := ut_utils.ut_owner;
    l_xmltable_stmt  clob;
    l_where_stmt     clob;
    l_select_stmt    clob;
    l_partition_stmt clob;
    l_equal_stmt     clob;
    l_join_on_stmt   clob;
    l_not_equal_stmt clob;
     
    function get_join_type(a_inclusion_compare in boolean,a_negated in boolean) return varchar2 is
    begin
     if a_inclusion_compare and not(a_negated) then
       return ' right outer join ';
     elsif a_inclusion_compare and a_negated then
       return ' inner join '; 
     else
       return ' full outer join ';
     end if;
    end;
  
  begin
    dbms_lob.createtemporary(l_compare_sql, true);
     
    --TODO: Resolve issues with collection and nested tables, can we extract by internal column name if defined e.g. xml of colval.id.getclobval()    
    
    gen_sql_pieces_out_of_cursor(a_other, a_join_by_list, 
      l_xmltable_stmt, l_select_stmt, l_partition_stmt, l_equal_stmt, 
      l_join_on_stmt, l_not_equal_stmt);
            
    l_temp_string := 'with exp as ( select ucd.* ';    
    ut_utils.append_to_clob(l_compare_sql, l_temp_string);
    ut_utils.append_to_clob(l_compare_sql,l_partition_stmt);
    
    l_temp_string := 'from (select ucd.item_data ';
    ut_utils.append_to_clob(l_compare_sql, l_temp_string);
    ut_utils.append_to_clob(l_compare_sql, l_select_stmt);
    
    l_temp_string := ',x.data_id ,'
                     || case when not a_unordered then 'position + x.item_no ' else 'rownum ' end 
                     ||'item_no from '|| l_ut_owner || '.ut_compound_data_tmp x, '
                     ||q'[xmltable('/ROWSET/ROW' passing x.item_data columns ]';   
    ut_utils.append_to_clob(l_compare_sql, l_temp_string); 
    
    if not a_unordered then
      ut_utils.append_to_clob(l_compare_sql,'POSITION for ordinality, ');
    end if;
    
    ut_utils.append_to_clob(l_compare_sql,l_xmltable_stmt);
    
    l_temp_string := q'[ item_data xmltype PATH '*' ) ucd where data_id = :self_guid ) ucd ) ,]';
    ut_utils.append_to_clob(l_compare_sql,l_temp_string);
    
    l_temp_string :='act as ( select ucd.* '; 
    ut_utils.append_to_clob(l_compare_sql, l_temp_string);
    ut_utils.append_to_clob(l_compare_sql, l_partition_stmt);
    
    l_temp_string := 'from (select ucd.item_data ';
    ut_utils.append_to_clob(l_compare_sql,l_temp_string);
    ut_utils.append_to_clob(l_compare_sql, l_select_stmt);
     
    l_temp_string := ',x.data_id, '
                     || case when not a_unordered then 'position + x.item_no ' else 'rownum ' end 
                     ||'item_no from ' || l_ut_owner || '.ut_compound_data_tmp x,'
                     ||q'[xmltable('/ROWSET/ROW' passing x.item_data columns ]' ;
    ut_utils.append_to_clob(l_compare_sql,l_temp_string);
    
    if not a_unordered then
      ut_utils.append_to_clob(l_compare_sql,'POSITION for ordinality, ');
    end if;
    
    ut_utils.append_to_clob(l_compare_sql,l_xmltable_stmt||q'[ item_data xmltype PATH '*') ucd where data_id = :other_guid ) ucd ) ]');
    
    l_temp_string :=  ' select a.item_data as act_item_data, a.data_id act_data_id,'
                       ||'e.item_data as exp_item_data, e.data_id exp_data_id, '||
                       case when a_unordered then 'rownum item_no' else 'nvl(e.item_no,a.item_no) item_no' end ||', nvl(e.dup_no,a.dup_no) dup_no '
                       ||'from act a '||get_join_type(a_inclusion_type,a_is_negated)||' exp e on ( ';
    ut_utils.append_to_clob(l_compare_sql,l_temp_string); 
    
    if a_unordered then 
      ut_utils.append_to_clob(l_compare_sql,' e.dup_no = a.dup_no and '); 
    end if;
       
    if a_join_by_xpath is null and a_unordered then
     -- If no key defined do the join on all columns
     ut_utils.append_to_clob(l_compare_sql,l_equal_stmt);
   elsif a_join_by_xpath is not null and a_unordered then
     -- If key defined do the join or these and where on diffrences   
     ut_utils.append_to_clob(l_compare_sql,l_join_on_stmt);         
   elsif not a_unordered then
     ut_utils.append_to_clob(l_compare_sql, 'a.item_no = e.item_no ' );
   end if;   
     
   ut_utils.append_to_clob(l_compare_sql,' ) where ');
   
  if (a_join_by_xpath is not null) and (a_unordered) and (not a_is_negated) then
       if l_not_equal_stmt is not null then
           ut_utils.append_to_clob(l_compare_sql,' ( '||l_not_equal_stmt||' ) or '); 
       end if;
   elsif not a_unordered then
     if l_not_equal_stmt is not null then
       ut_utils.append_to_clob(l_compare_sql,' ( '||l_not_equal_stmt||' ) or ');
     end if;
   end if;

   --If its inlcusion we expect a actual set to fully match and have no extra elements over expected
   if a_inclusion_type and not(a_is_negated) then
     l_temp_string := ' ( a.data_id is null ) '; 
   else
     l_temp_string := ' (a.data_id is null or e.data_id is null) ';
   end if;
   ut_utils.append_to_clob(l_compare_sql,l_temp_string);
    
   --dbms_output.put_line(l_compare_sql);
   return l_compare_sql;
  end;
 
  procedure insert_diffs_result(a_diff_tab t_diff_tab, a_diff_id raw) is
  begin  
    forall idx in 1..a_diff_tab.count
    insert into ut3.ut_compound_data_diff_tmp
    ( diff_id, act_item_data, act_data_id, exp_item_data, exp_data_id, item_no, duplicate_no )
    values 
    (a_diff_id, 
    xmlelement( name "ROW", a_diff_tab(idx).act_item_data), a_diff_tab(idx).act_data_id,
    xmlelement( name "ROW", a_diff_tab(idx).exp_item_data), a_diff_tab(idx).exp_data_id,
    a_diff_tab(idx).item_no, a_diff_tab(idx).dup_no);
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

  function filter_out_cols(a_cursor_info ut_cursor_column_tab, a_current_list ut_varchar2_list,a_include boolean) 
  return ut_cursor_column_tab is
    l_sql varchar2(32767) :=
    q'[with 
      sorted as
      (select r_num,regexp_substr(t.column_value, '[^/]+', 1, commas.column_value) as colval,commas.column_value lev
       from (select row_number() over(order by 1) r_num, column_value from ((table(:a_current_list)))) t,
              table(cast(multiset 
              (select level from dual connect by level <= length(regexp_replace(t.column_value,'[^/]+')) + 1) as sys.odcinumberlist)) commas
              order by r_num,lev),
      hier as
        (select r_num,lev,colval column_name,lag(colval, 1) over(partition by r_num order by lev) parent_name from sorted),
     constructed as (
     select lev,column_name,parent_name from hier),
     t1(column_name, parent_name) AS (
     select column_name,parent_name from table(:a_cursor_info) where parent_name is null
    union all
    select t2.column_name,t2.parent_name from table(:a_cursor_info) t2, t1 where t2.parent_name = t1.column_name)
    select ut_cursor_column(i.column_name,i.column_schema,i.column_type_name, i.column_prec,i.column_scale,i.column_len, i.parent_name, 
     i.hierarchy_level,i.column_position, i.column_type)
    from t1 join table(:a_cursor_info) i on ( nvl(t1.parent_name,1) = nvl(i.parent_name,1) and t1.column_name = i.column_name)
    ]';

    l_result ut_cursor_column_tab := ut_cursor_column_tab();
  begin
   --TODO : Get this query tidy up
   if a_include then 
    l_sql := l_sql || ' join constructed c on ( nvl(t1.parent_name,1) = nvl(c.parent_name,1) and t1.column_name = c.column_name)';
   else
    l_sql := l_sql ||'left outer join constructed c on ( nvl(t1.parent_name,1) = nvl(c.parent_name,1) and t1.column_name = c.column_name)
    where c.column_name is null';
   end if;
    
   execute immediate l_sql bulk collect into l_result
     using a_current_list,a_cursor_info,a_cursor_info,a_cursor_info;
     
   return l_result;
  end;
  
  function inc_exc_columns_from_cursor (a_cursor_info ut_cursor_column_tab, a_exclude_xpath ut_varchar2_list, a_include_xpath ut_varchar2_list)
  return ut_cursor_column_tab is
    l_filtered_set ut_varchar2_list := ut_varchar2_list();
    l_result ut_cursor_column_tab := ut_cursor_column_tab();
    l_include boolean;
  begin
    -- if include and exclude is not null its columns from include minus exclude
    -- If inlcude is not null and exclude is null cursor will have only include
    -- If exclude is not null and include is null cursor will have all except exclude
    if a_include_xpath.count > 0 and a_exclude_xpath.count > 0 then
      select col_names bulk collect into l_filtered_set
      from(
        select regexp_replace(column_value,'^((/ROW/)|^(//)|^(/\*/))?(.*)','\5') col_names
        from table(a_include_xpath)
        minus
        select regexp_replace(column_value,'^((/ROW/)|^(//)|^(/\*/))?(.*)','\5') col_names
        from table(a_exclude_xpath)
       );
       l_include := true;
    elsif a_include_xpath.count > 0 and a_exclude_xpath.count = 0 then
      select regexp_replace(column_value,'^((/ROW/)|^(//)|^(/\*/))?(.*)','\5') col_names
      bulk collect into l_filtered_set
      from table(a_include_xpath);
      l_include := true;
    elsif a_include_xpath.count = 0 and a_exclude_xpath.count > 0 then
      select regexp_replace(column_value,'^((/ROW/)|^(//)|^(/\*/))?(.*)','\5') col_names
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
  
end; 
/
