create or replace package body ut_compound_data_helper is
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

  type t_type_name_map is table of varchar2(100) index by binary_integer;
  g_type_name_map t_type_name_map;

  function get_column_type(a_desc_rec dbms_sql.desc_rec3) return varchar2 is
    l_result varchar2(500) := 'unknown datatype';
    begin
      if g_type_name_map.exists(a_desc_rec.col_type) then
        l_result := g_type_name_map(a_desc_rec.col_type);
      elsif a_desc_rec.col_schema_name is not null and a_desc_rec.col_type_name is not null then
        l_result := a_desc_rec.col_schema_name||'.'||a_desc_rec.col_type_name;
      end if;
      return l_result;
    end;

  function get_columns_info(a_columns_tab dbms_sql.desc_tab3, a_columns_count integer) return ut_key_value_pairs is
    l_result ut_key_value_pairs := ut_key_value_pairs();
    begin
      for i in 1 .. a_columns_count loop
        l_result.extend;
        l_result(l_result.last) := ut_key_value_pair(a_columns_tab(i).col_name, get_column_type(a_columns_tab(i)));
      end loop;
      return l_result;
    end;

  function get_columns_info(a_cursor in out nocopy sys_refcursor) return xmltype is
    l_cursor_number  integer;
    l_columns_count  pls_integer;
    l_columns_desc   dbms_sql.desc_tab3;
    l_result         xmltype;
    l_columns_tab    ut_key_value_pairs;
    begin
      if a_cursor is null or not a_cursor%isopen then
        return null;
      end if;
      l_cursor_number := dbms_sql.to_cursor_number( a_cursor );
      dbms_sql.describe_columns3( l_cursor_number, l_columns_count, l_columns_desc );
      a_cursor := dbms_sql.to_refcursor( l_cursor_number );
      l_columns_tab := get_columns_info( l_columns_desc, l_columns_count);

      select 
        XMLELEMENT("ROW", xmlagg(xmlelement(evalname ut_utils.xmlgen_escaped_string(key),
                                           XMLATTRIBUTES(key AS "xml_valid_name"), 
                                           value)))
      into l_result 
      from table(l_columns_tab );

      return l_result;
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

  function get_columns_diff(
    a_expected xmltype, a_actual xmltype, a_exclude_xpath varchar2, a_include_xpath varchar2
  ) return tt_column_diffs is
    l_column_filter  varchar2(32767);
    l_sql            varchar2(32767);
    l_results        tt_column_diffs;
  begin
    l_column_filter := get_columns_filter(a_exclude_xpath, a_include_xpath);
    l_sql := q'[
      with
        expected_cols as ( select :a_expected as item_data from dual ),
        actual_cols as ( select :a_actual as item_data from dual ),
  expected_cols_info as (
          select e.*,
                 replace(expected_type,'VARCHAR2','CHAR') expected_type_compare
            from (
                   SELECT rownum expected_pos,
                   xt.name expected_name,
                   xt.type expected_type
         FROM   (select ]'||l_column_filter||q'[ from expected_cols ucd) x,
           XMLTABLE('/ROW/*'
             PASSING x.item_data
             COLUMNS 
               name     VARCHAR2(4000)  PATH '@xml_valid_name',
               type      VARCHAR2(4000) PATH '/' 
             ) xt
            ) e
        ),
        actual_cols_info as (
          select a.*,
                 replace(actual_type,'VARCHAR2','CHAR') actual_type_compare
            from (
                   SELECT rownum actual_pos,
                   xt.name actual_name,
                   xt.type actual_type
         FROM    (select ]'||l_column_filter||q'[ from actual_cols ucd) x,
           XMLTABLE('/ROW/*'
             PASSING x.item_data
             COLUMNS 
               name     VARCHAR2(4000)  PATH '@xml_valid_name',
               type      VARCHAR2(4000) PATH '/' 
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

  function get_rows_diff(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_join_by_xpath varchar2
  ) return tt_row_diffs is
    l_column_filter varchar2(32767);
    l_results       tt_row_diffs;
    l_sql varchar2(32767); -- REMOVE LATER also for unorder
  begin
    l_column_filter := get_columns_filter(a_exclude_xpath,a_include_xpath);
    
   /**
    * Since its unordered search we cannot select max rows from diffs as we miss some comparision records
    * We will restrict output on higher level of select
    */
    
    l_sql := q'[
      with
        diff_info as (select item_hash from ut_compound_data_diff_tmp ucdc where diff_id = :diff_guid)
      select rn,diff_type,diffed_row
        from (select dense_rank() over (order by pk_hash) as rn, diff_type,data_item diffed_row
                from (select nvl(exp.pk_hash, act.pk_hash) pk_hash,
                             xmlserialize(content exp.row_data no indent)  exp_item,
                             xmlserialize(content act.row_data no indent)  act_item
                      from 
                        (select ucd.*, row_number() over(partition by pk_hash order by row_hash) duplicate_no
                          from 
                            (select ucd.column_value row_data,
                               dbms_crypto.hash( value(ucd).getclobval(),3) row_hash,
                               dbms_crypto.hash( extract(value(ucd),']'|| a_join_by_xpath ||q'[').getClobVal(),3/*HASH_SH1*/) pk_hash 
                             from 
                               (select ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                                from ut_compound_data_tmp ucd
                                where ucd.data_id = :self_guid
                               and ucd.item_hash in (select i.item_hash from diff_info i)
                               ) r,
                               table( xmlsequence( extract(r.item_data,'/*') ) ) ucd
                             ) ucd
                      )  exp
                     join (
                          select ucd.*, row_number() over(partition by pk_hash order by row_hash) duplicate_no
                          from 
                            (select ucd.column_value row_data,
                             dbms_crypto.hash( value(ucd).getclobval(),3/*HASH_SH1*/) row_hash,
                             dbms_crypto.hash( extract(value(ucd),']'|| a_join_by_xpath ||q'[').getClobVal(),3/*HASH_SH1*/) pk_hash 
                             from 
                               (select  ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                                from ut_compound_data_tmp ucd
                                where ucd.data_id = :other_guid
                                and ucd.item_hash in (select i.item_hash from diff_info i)
                               ) r,
                               table( xmlsequence( extract(r.item_data,'/*') ) ) ucd
                          ) ucd
                      )  act
                          on exp.pk_hash = act.pk_hash  and exp.duplicate_no = act.duplicate_no
                       where exp.row_hash != act.row_hash
                       or exp.row_hash is null 
                       or act.row_hash is null
                     )
              unpivot ( data_item for diff_type in (exp_item as 'Expected:', act_item as 'Actual:') )
             )
             where rownum < :max_rows
      order by 1, 2]';
      
    execute immediate l_sql
    bulk collect into l_results
    using a_diff_id,
    a_exclude_xpath, a_include_xpath, a_expected_dataset_guid,
    a_exclude_xpath, a_include_xpath, a_actual_dataset_guid,
    a_max_rows;
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
        diff_info as (select item_no from ut_compound_data_diff_tmp ucdc where diff_id = :diff_guid and rownum <= :max_rows)
      select *
        from (select rn, diff_type, xmlserialize(content data_item no indent) diffed_row
                from (select nvl(exp.rn, act.rn) rn,
                             xmlagg(exp.col order by exp.col_no) exp_item,
                             xmlagg(act.col order by act.col_no) act_item
                        from (select r.item_no as rn, rownum col_no, s.column_value col,
                                     s.column_value.getRootElement() col_name,
                                     s.column_value.getclobval() col_val
                                from (select ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                                        from ut_compound_data_tmp ucd
                                       where ucd.data_id = :self_guid
                                         and ucd.item_no in (select i.item_no from diff_info i)
                                    ) r,
                                     table( xmlsequence( extract(r.item_data,'/*/*') ) ) s
                             ) exp
                        join (
                              select item_no as rn, rownum col_no, s.column_value col,
                                     s.column_value.getRootElement() col_name,
                                     s.column_value.getclobval() col_val
                                from (select ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                                        from ut_compound_data_tmp ucd
                                       where ucd.data_id = :other_guid
                                         and ucd.item_no in (select i.item_no from diff_info i)
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
             xmlserialize(content nvl(exp.item_data, act.item_data) no indent) diffed_row
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

  function get_rows_diff_unordered(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2
  ) return tt_row_diffs is
    l_column_filter varchar2(32767);
    l_results       tt_row_diffs;
  begin
    l_column_filter := get_columns_filter(a_exclude_xpath,a_include_xpath);
    
    /**
    * Since its unordered search we cannot select max rows from diffs as we miss some comparision records
    * We will restrict output on higher level of select
    */
    execute immediate q'[with
      diff_info as (select item_hash from ut_compound_data_diff_tmp ucdc where diff_id = :diff_guid)
      select duplicate_no,
             diffed_type,
             diffed_row
      from
      (select  
        coalesce(exp.duplicate_no,act.duplicate_no) duplicate_no,
        case 
          when act.row_hash is null then 
            'miss row'  
          else 'extra row' 
        end diffed_type,
        case when exp.row_hash is null then 
          xmlserialize(content act.row_data no indent) 
        when act.row_hash is null then
          xmlserialize(content exp.row_data no indent) 
        end diffed_row
         from (select ucd.*, row_number() over(partition by row_hash order by row_hash) duplicate_no
            from (select ucd.column_value row_data,
                    dbms_crypto.hash( value(ucd).getclobval(),3) row_hash
                    from (select ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                        from ut_compound_data_tmp ucd
                        where ucd.data_id = :self_guid
                        and ucd.item_hash in (select i.item_hash from diff_info i)
                       ) r,
                  table( xmlsequence( extract(r.item_data,'/*') ) ) ucd
              ) ucd
          )  exp
      full outer join
        (select ucd.*, row_number() over(partition by row_hash order by row_hash) duplicate_no
         from (select ucd.column_value row_data,
                      dbms_crypto.hash( value(ucd).getclobval(),3/*HASH_SH1*/) row_hash
                      from (select  ]'||l_column_filter||q'[, ucd.item_no, ucd.item_data item_data_no_filter
                     from ut_compound_data_tmp ucd
                     where ucd.data_id = :other_guid
                     and ucd.item_hash in (select i.item_hash from diff_info i)
                     ) r,
               table( xmlsequence( extract(r.item_data,'/*') ) ) ucd
               ) ucd
       )  act
      on   exp.row_hash = act.row_hash
          and exp.duplicate_no = act.duplicate_no
      where exp.row_hash is null or act.row_hash is null ) where rownum < :max_rows ]'
    bulk collect into l_results
    using a_diff_id,
    a_exclude_xpath, a_include_xpath, a_expected_dataset_guid,
    a_exclude_xpath, a_include_xpath, a_actual_dataset_guid,
    a_max_rows;
    
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

begin
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
  
end;
/