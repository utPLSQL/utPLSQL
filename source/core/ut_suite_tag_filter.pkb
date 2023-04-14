create or replace package body ut_suite_tag_filter is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2023 utPLSQL Project

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
  * Constants use in postfix and infix transformations
  */
  gc_operators constant ut_varchar2_list := ut_varchar2_list('|','&','!');  
  gc_unary_operators constant ut_varchar2_list := ut_varchar2_list('!'); -- right side associative operator
  gc_binary_operators constant ut_varchar2_list := ut_varchar2_list('|','&'); -- left side associative operator
    
  type t_precedence_table is table of number index by varchar2(1);    
  g_precedence t_precedence_table; 

  function tokenize_tags_string(a_tags in varchar2) return ut_varchar2_list is
    l_tags_tokens ut_varchar2_list := ut_varchar2_list();  
  begin
    --Tokenize a string into operators and tags
    select regexp_substr(a_tags,'([^!()|&]+)|([!()|&])', 1, level) as string_parts
    bulk collect into l_tags_tokens
    from dual connect by regexp_substr (a_tags, '([^!()|&]+)|([!()|&])', 1, level) is not null;
    
    return l_tags_tokens;
  end;

  /*
    To support a legact tag notation 
    , = OR
    - = NOT
    we will perform a replace of that characters into
    new notation.
    | = OR
    & = AND
    !  = NOT
  */
  function replace_legacy_tag_notation(a_tags varchar2
  ) return varchar2 is
    l_tags ut_varchar2_list := ut_utils.string_to_table(a_tags,',');
    l_tags_include varchar2(4000);
    l_tags_exclude varchar2(4000);
    l_return_tag varchar2(4000);
  begin
    if instr(a_tags,',') > 0 or instr(a_tags,'-') > 0 then 

      select '('||listagg( t.column_value,'|')
        within group( order by column_value)||')' 
      into l_tags_include
      from table(l_tags) t
      where t.column_value not like '-%';
      
      select '('||listagg( replace(t.column_value,'-','!'),' & ')
        within group( order by column_value)||')'
      into l_tags_exclude
      from table(l_tags) t
      where t.column_value like '-%';   
      

      l_return_tag:=
        case 
          when l_tags_include <> '()' and l_tags_exclude <> '()'
            then l_tags_include || ' & ' || l_tags_exclude
          when l_tags_include <> '()'
            then l_tags_include
          when l_tags_exclude <> '()'
            then l_tags_exclude 
        end;
    else 
      l_return_tag := a_tags;
    end if;      
    return l_return_tag;
  end;
    
  /*
    https://stackoverflow.com/questions/29634992/shunting-yard-validate-expression
  */
  function shunt_logical_expression(a_tags in ut_varchar2_list) return ut_varchar2_list is
    l_operator_stack ut_stack := ut_stack();
    l_rnp_tokens ut_varchar2_list := ut_varchar2_list();
    l_token varchar2(32767);
    l_expect_operand boolean := true;
    l_expect_operator boolean := false;
    l_idx pls_integer;
  begin    
    l_idx := a_tags.first;
    --Exuecute modified shunting algorithm
    WHILE (l_idx is not null) loop
      l_token := a_tags(l_idx);
      if (l_token member of gc_operators and l_token member of gc_binary_operators) then
        if not(l_expect_operator) then 
          raise_application_error(ut_utils.gc_invalid_tag_expression, 'Invalid Tag expression'); 
        end if;
        while l_operator_stack.top > 0 and (g_precedence(l_operator_stack.peek) > g_precedence(l_token))  loop
          l_rnp_tokens.extend;
          l_rnp_tokens(l_rnp_tokens.last) := l_operator_stack.pop;
        end loop;
        l_operator_stack.push(a_tags(l_idx));
        l_expect_operand := true;
        l_expect_operator:= false;
      elsif (l_token member of gc_operators and l_token member of gc_unary_operators) then  
        if not(l_expect_operand) then 
          raise_application_error(ut_utils.gc_invalid_tag_expression, 'Invalid Tag expression'); 
        end if;        
        l_operator_stack.push(a_tags(l_idx));
        l_expect_operand := true;
        l_expect_operator:= false;   
      elsif l_token = '(' then
        if not(l_expect_operand) then 
          raise_application_error(ut_utils.gc_invalid_tag_expression, 'Invalid Tag expression'); 
        end if;        
        l_operator_stack.push(a_tags(l_idx));
        l_expect_operand := true;
        l_expect_operator:= false;      
      elsif l_token = ')' then
        if not(l_expect_operator) then 
          raise_application_error(ut_utils.gc_invalid_tag_expression, 'Invalid Tag expression'); 
        end if;        
        while l_operator_stack.peek <> '(' loop
          l_rnp_tokens.extend;
          l_rnp_tokens(l_rnp_tokens.last) := l_operator_stack.pop;
        end loop;
        l_operator_stack.pop; --Pop the open bracket and discard it
        l_expect_operand := false;
        l_expect_operator:= true;           
      else
        if not(l_expect_operand) then 
          raise_application_error(ut_utils.gc_invalid_tag_expression, 'Invalid Tag expression'); 
        end if;
        l_rnp_tokens.extend;
        l_rnp_tokens(l_rnp_tokens.last) :=l_token;
        l_expect_operator := true;
        l_expect_operand := false;
      end if;
      
      l_idx := a_tags.next(l_idx);
    end loop;
    
    while l_operator_stack.peek is not null loop
        if l_operator_stack.peek in ('(',')') then 
          raise_application_error(ut_utils.gc_invalid_tag_expression, 'Invalid Tag expression'); 
        end if;         
        l_rnp_tokens.extend;
        l_rnp_tokens(l_rnp_tokens.last):=l_operator_stack.pop;         
    end loop;
  
    return l_rnp_tokens;
  end shunt_logical_expression;
  
  function conv_postfix_to_infix_sql(a_postfix_exp in ut_varchar2_list) 
    return varchar2 is
    l_infix_stack ut_stack := ut_stack();
    l_right_side varchar2(32767);
    l_left_side varchar2(32767);
    l_infix_exp varchar2(32767);
    l_member_token varchar2(20) := ' member of tags';
    l_idx pls_integer;
  begin
    l_idx := a_postfix_exp.first;
    while ( l_idx is not null) loop
      --If token is operand but also single tag
      if regexp_count(a_postfix_exp(l_idx),'[!()|&]') = 0 then
        l_infix_stack.push(q'[']'||a_postfix_exp(l_idx)||q'[']'||l_member_token);
      --If token is operand but containing other expressions
      elsif a_postfix_exp(l_idx) not member of gc_operators then
        l_infix_stack.push(a_postfix_exp(l_idx));
      --If token is unary operator not  
      elsif a_postfix_exp(l_idx) member of gc_unary_operators then
        l_right_side := l_infix_stack.pop;
        l_infix_exp := a_postfix_exp(l_idx)||'('||l_right_side||')';
        l_infix_stack.push(l_infix_exp);
      --If token is binary operator  
      elsif a_postfix_exp(l_idx) member of gc_binary_operators then
        l_right_side := l_infix_stack.pop;
        l_left_side := l_infix_stack.pop;
        l_infix_exp := '('||l_left_side||a_postfix_exp(l_idx)||l_right_side||')';
        l_infix_stack.push(l_infix_exp);
      end if;
      l_idx := a_postfix_exp.next(l_idx);
    end loop;
    
    return l_infix_stack.pop;
  end conv_postfix_to_infix_sql;

  function create_where_filter(a_tags varchar2
  ) return varchar2 is
    l_tags varchar2(4000);
    l_tokenized_tags ut_varchar2_list;
  begin
    l_tags := replace(replace_legacy_tag_notation(a_tags),' ');
    l_tags := conv_postfix_to_infix_sql(shunt_logical_expression(tokenize_tags_string(l_tags)));
    l_tags := replace(l_tags, '|',' or ');
    l_tags := replace(l_tags ,'&',' and ');
    l_tags := replace(l_tags ,'!','not');
    return l_tags;    
  end;  


  /*
    Having a base set of suites we will do a further filter down if there are
    any tags defined.
  */      
  function get_tags_suites (
    a_suite_items ut_suite_cache_rows,
    a_tags varchar2
  ) return ut_suite_cache_rows is
    l_suite_tags      ut_suite_cache_rows := ut_suite_cache_rows();  
    l_sql varchar2(32000);
    l_tags varchar2(4000):= create_where_filter(a_tags);
  begin
    l_sql :=
    q'[
with 
  suites_mv as (
    select c.id,value(c) as obj,c.path as path,c.self_type,c.object_owner,c.tags
    from table(:suite_items) c
  ),
  suites_matching_expr as (
    select c.id,c.path as path,c.self_type,c.object_owner,c.tags
    from suites_mv c
    where c.self_type in ('UT_SUITE','UT_CONTEXT')
    and ]'||l_tags||q'[
  ),
  tests_matching_expr as (
    select c.id,c.path as path,c.self_type,c.object_owner,c.tags
    from suites_mv c where c.self_type in ('UT_TEST')
    and ]'||l_tags||q'[
  ),  
  tests_with_tags_inh_from_suite as (
   select c.id,c.self_type,c.path,c.tags multiset union distinct t.tags tags,c.object_owner
   from suites_mv c join suites_matching_expr t 
     on (c.path||'.' like t.path || '.%' /*all descendants and self*/ and c.object_owner = t.object_owner)
  ),
  tests_with_tags_prom_to_suite as (
    select c.id,c.self_type,c.path,c.tags multiset union distinct t.tags tags,c.object_owner
    from suites_mv c join tests_matching_expr t 
      on (t.path||'.' like c.path || '.%' /*all ancestors and self*/ and c.object_owner = t.object_owner)
  )
  select obj from suites_mv c,
    (select id,row_number() over (partition by id order by id) r_num from
      (select id
      from tests_with_tags_prom_to_suite tst
      where ]'||l_tags||q'[        
      union all
      select id from tests_with_tags_inh_from_suite tst
      where ]'||l_tags||q'[   
      )
    ) t where c.id = t.id and r_num = 1 ]';
    
    execute immediate l_sql bulk collect into  l_suite_tags using a_suite_items;
    return l_suite_tags;  
  end;

  function apply(
    a_unfiltered_rows  ut_suite_cache_rows,
    a_tags             varchar2 := null
  ) return ut_suite_cache_rows is
    l_suite_items     ut_suite_cache_rows := a_unfiltered_rows;  
  begin
    if length(a_tags) > 0 then
      l_suite_items := get_tags_suites(l_suite_items,a_tags);
    end if;

    return l_suite_items;
  end;

begin
    --Define operators precedence
    g_precedence('!'):=4;
    g_precedence('&'):=3;
    g_precedence('|'):=2;
    g_precedence(')'):=1;
    g_precedence('('):=1;
  
end ut_suite_tag_filter;
/
