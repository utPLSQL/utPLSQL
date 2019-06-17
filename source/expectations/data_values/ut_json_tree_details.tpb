create or replace type body ut_json_tree_details as

  member function get_json_type(a_json_piece json_element_t) return varchar2 is
  begin
    return
      case
        when a_json_piece.is_object    then 'object'
        when a_json_piece.is_array     then 'array'
        when a_json_piece.is_string    then 'string'
        when a_json_piece.is_number    then 'number'
        when a_json_piece.is_boolean   then 'boolean'
        when a_json_piece.is_true      then 'true'
        when a_json_piece.is_false     then 'false'
        when a_json_piece.is_null      then 'null'
        when a_json_piece.is_date      then 'date'
        when a_json_piece.is_timestamp then 'timestamp'
        when a_json_piece.is_scalar    then 'scalar'
        else null
      end;
  end;
   
   member function get_json_value(a_json_piece json_element_t, a_key varchar2) return varchar2 is
     l_json_el json_element_t;
     l_val varchar2(4000);
   begin
     l_json_el := treat(a_json_piece as json_object_t).get(a_key);
     case 
       when l_json_el.is_string    then l_val := ut_utils.to_string(l_json_el.to_string(),null);
       when l_json_el.is_number    then l_val := ut_utils.to_string(l_json_el.to_number());
       when l_json_el.is_boolean   then l_val := ut_utils.to_string(l_json_el.to_boolean());
--        when l_json_el.is_true      then l_val := ut_utils.to_string(l_json_el.to_boolean());
--        when l_json_el.is_false     then l_val := ut_utils.to_string(l_json_el.to_boolean());
       when l_json_el.is_date      then l_val := ut_utils.to_string(l_json_el.to_date());
       when l_json_el.is_timestamp then l_val := ut_utils.to_string(l_json_el.to_date());
       else null;
      end case;
     return l_val;
   end;
  
   member function get_json_value(a_json_piece json_element_t, a_key integer) return varchar2 is
     l_json_el json_element_t;
     l_val varchar2(4000);    
   begin
     l_json_el := treat(a_json_piece as json_array_t).get(a_key);
     case 
       when l_json_el.is_string    then l_val := ut_utils.to_string(l_json_el.to_string(),null);
       when l_json_el.is_number    then l_val := ut_utils.to_string(l_json_el.to_number());
       when l_json_el.is_boolean   then l_val := ut_utils.to_string(l_json_el.to_boolean());
--        when l_json_el.is_true      then l_val := ut_utils.to_string(l_json_el.to_boolean());
--        when l_json_el.is_false     then l_val := ut_utils.to_string(l_json_el.to_boolean());
       when l_json_el.is_date      then l_val := ut_utils.to_string(l_json_el.to_date());
       when l_json_el.is_timestamp then l_val := ut_utils.to_string(l_json_el.to_date());
       else null;
      end case;
     return l_val;
   end;  
      
  member procedure add_json_leaf(
    self in out nocopy ut_json_tree_details,
    a_element_name     varchar2,
    a_element_value    varchar2,
    a_parent_name      varchar2,
    a_access_path      varchar2,
    a_hierarchy_level  integer,
    a_index_position   integer,
    a_json_type        varchar2,
    a_parent_type      varchar2,
    a_array_element    integer := 0,
    a_parent_path      varchar2
  ) is
  begin
    self.json_tree_info.extend;
    self.json_tree_info(self.json_tree_info.last) :=
      ut_json_leaf(
        a_element_name, a_element_value, a_parent_name, a_access_path,
        a_hierarchy_level, a_index_position,a_json_type, a_parent_type,
        a_array_element, a_parent_path
      );
  end;
  
  member procedure traverse_object(
    self in out nocopy ut_json_tree_details,
    a_json_piece       json_element_t,
    a_parent_name      varchar2 := null,
    a_hierarchy_level  integer := 1,
    a_access_path      varchar2 := '$'
  ) as
    l_keys      json_key_list;
    l_object    json_object_t := treat(a_json_piece as json_object_t);
    l_path      varchar2(32767);
    l_type      varchar2(50);
    l_name      varchar2(4000);
  begin
    l_keys := coalesce(l_object.get_keys,json_key_list());

    for i in 1 .. l_keys.count loop
      l_type := get_json_type(l_object.get(l_keys(i)));
      l_name := '"'||l_keys(i)||'"';
      l_path := a_access_path||'.'||l_name;

      add_json_leaf(
        l_name,
        get_json_value(l_object,l_keys(i)),
        a_parent_name,
        l_path,
        a_hierarchy_level,
        i,
        l_type,
        'object',
        0,
        a_access_path
      );
      case l_type
        when 'array' then
          traverse_array (
            treat (l_object.get (l_keys(i)) as json_array_t),
            l_name,
            a_hierarchy_level + 1,
            l_path
          );
        when 'object' then
          traverse_object(
            treat (l_object.get (l_keys(i)) as json_object_t),
            l_name,
            a_hierarchy_level+1,
            l_path
          );
        else
          null;
      end case;
   end loop; 
  end traverse_object;
 
  member procedure traverse_array(
    self in out nocopy ut_json_tree_details,
    a_json_piece       json_element_t,
    a_parent_name      varchar2 := null,
    a_hierarchy_level  integer := 1,
    a_access_path      varchar2 := '$'
  ) as
    l_array     json_array_t;
    l_type      varchar2(50);
    l_name      varchar2(4000);
    l_path      varchar2(32767);
  begin
    l_array  := treat(a_json_piece as json_array_t);

    for i in 0 .. l_array.get_size - 1  loop
      l_type := get_json_type(l_array.get(i));
      l_name := case when l_type = 'object' then l_type else l_array.get(i).stringify end;
      l_path := a_access_path||'['||i||']';

      add_json_leaf(
        l_name,
        get_json_value(a_json_piece,i),
        a_parent_name,
        l_path,
        a_hierarchy_level,
        i,
        l_type,
        'array',
        1,
        l_path
      );
      case l_type
        when 'array' then
          traverse_array (
            treat (l_array.get (i) as json_array_t),
            l_name,
            a_hierarchy_level + 1,
            l_path
          );
        when 'object' then
          traverse_object(
            treat (l_array.get (i) as json_object_t),
            l_name,
            a_hierarchy_level + 1,
            l_path
          );
        else
          null;
      end case;
   end loop; 
  end traverse_array;
 
  member procedure init(self in out nocopy ut_json_tree_details,a_json_doc in json_element_t, a_level_in integer := 0) is
  begin
    if a_json_doc.is_object then
      traverse_object(treat (a_json_doc as json_object_t));
    elsif a_json_doc.is_array then
      traverse_array(treat (a_json_doc as json_array_t));
    end if;  
  end;
 
  constructor function ut_json_tree_details(
     self in out nocopy ut_json_tree_details, a_json_doc in json_element_t, a_level_in integer := 0
   ) return self as result is  
  begin
    self.json_tree_info := ut_json_leaf_tab();
    if a_json_doc is not null then 
      init(a_json_doc,a_level_in);
    end if;
    return;
  end;
  
end;
/
