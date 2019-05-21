create or replace type body ut_json_tree_details as

  --TODO : Equal to be reviewed specially order of arrays and order of objects
  member function equals( a_other ut_json_tree_details, a_match_options ut_matcher_options ) return boolean is
   l_diffs integer;
  begin       
    select count(1) into l_diffs
      from table(self.json_tree_info) a
      full outer join table(a_other.json_tree_info) e
        on decode(a.parent_name,e.parent_name,1,0)= 1
       and decode(a.element_name,e.element_name,1,0) = 1
       and a.json_type = e.json_type
       and a.hierarchy_level = e.hierarchy_level
       and decode(a.element_value,e.element_value,1,0) = 1
     where a.element_name is null or e.element_name is null;
    return l_diffs = 0;
  end;

   member function get_json_type(a_json_piece json_element_t) return varchar2 is
   begin
    return case 
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
   
   member function get_json_value(a_json_piece json_object_t,a_key varchar2) return varchar2 is
     l_json_el json_element_t := a_json_piece.get (a_key);
     l_val varchar2(4000);
   begin
     case 
       when l_json_el.is_string       then l_val := a_json_piece.get_string(a_key);
       when l_json_el.is_number       then l_val := to_char(a_json_piece.get_number(a_key));
       when l_json_el.is_boolean      then l_val := ut_utils.boolean_to_int(a_json_piece.get_boolean(a_key));
       when l_json_el.is_true         then l_val := ut_utils.boolean_to_int(a_json_piece.get_boolean(a_key));
       when l_json_el.is_false        then l_val := ut_utils.boolean_to_int(a_json_piece.get_boolean(a_key));
       when l_json_el.is_date         then l_val  := to_char(a_json_piece.get_date(a_key),'DD/MM/RRRR');
       when a_json_piece.is_timestamp then l_val  := to_char(a_json_piece.get_date(a_key),'DD/MM/RRRR HH24:MI:SS AM');
       else null;
      end case;
     return l_val;
   end;
  
   member function get_json_value(a_json_piece json_array_t,a_key integer) return varchar2 is
     l_json_el json_element_t := a_json_piece.get (a_key);
     l_val varchar2(4000);
   begin
     case 
       when l_json_el.is_string       then l_val := a_json_piece.get_string(a_key);
       when l_json_el.is_number       then l_val := to_char(a_json_piece.get_number(a_key));
       when l_json_el.is_boolean      then l_val := ut_utils.boolean_to_int(a_json_piece.get_boolean(a_key));
       when l_json_el.is_true         then l_val := ut_utils.boolean_to_int(a_json_piece.get_boolean(a_key));
       when l_json_el.is_false        then l_val := ut_utils.boolean_to_int(a_json_piece.get_boolean(a_key));
       when l_json_el.is_date         then l_val  := to_char(a_json_piece.get_date(a_key),'DD/MM/RRRR');
       when a_json_piece.is_timestamp then l_val  := to_char(a_json_piece.get_date(a_key),'DD/MM/RRRR HH24:MI:SS AM');
       else null;
      end case;
     return l_val;
   end;  
   
   member function get_json_size(a_json_piece json_object_t) return integer is
   begin
     return a_json_piece.get_size;
   end;
   
   member procedure add_json_leaf(self in out nocopy ut_json_tree_details, a_element_name varchar2, a_element_value varchar2,
     a_parent_name varchar2, a_access_path varchar2, a_hierarchy_level integer, a_index_position integer, 
     a_json_type in varchar2, a_parent_type in varchar2, a_array_element integer := 0) is
  begin
    self.json_tree_info.extend;
    self.json_tree_info(self.json_tree_info.last) := ut_json_leaf(a_element_name,a_element_value,a_parent_name,a_access_path,
      a_hierarchy_level, a_index_position,a_json_type, a_parent_type, a_array_element);
  end;
  
  member procedure traverse_object(self in out nocopy ut_json_tree_details, a_json_piece json_object_t,
    a_parent_name varchar2 := null, a_hierarchy_level integer := 1, a_access_path varchar2 := null ) as
    l_keys      json_key_list;
  begin
    l_keys := coalesce(a_json_piece.get_keys,json_key_list()); 
    
    for indx in 1 .. l_keys.count
    loop 
          add_json_leaf(l_keys(indx),
                   get_json_value(a_json_piece,l_keys(indx)),
                   a_parent_name,
                   a_access_path||'.'||l_keys(indx),
                   a_hierarchy_level,
                   indx,
                   get_json_type(a_json_piece.get (l_keys(indx))),
                   'object'
                   ); 
      case get_json_type(a_json_piece.get(l_keys(indx)))
        when 'array' then
            traverse_array ( 
              treat (a_json_piece.get (l_keys(indx)) as json_array_t), 
              l_keys(indx),
              a_hierarchy_level + 1,
              a_access_path||'.'||l_keys(indx)
              ); 
        when 'object' then
            traverse_object( treat (a_json_piece.get (l_keys(indx)) as json_object_t),
              l_keys (indx),
              a_hierarchy_level+1,
              a_access_path||'.'||l_keys(indx)
              );
        else null;      
      end case;
   end loop; 
  end traverse_object;
 
  member procedure traverse_array(self in out nocopy ut_json_tree_details, a_json_piece json_array_t, 
     a_parent_name varchar2 := null, a_hierarchy_level integer := 1, a_access_path varchar2 := null ) as
    l_array     json_array_t;
  begin
    l_array  := a_json_piece;
    
    for indx in 0 .. l_array.get_size - 1 
    loop 
           add_json_leaf(l_array.get(indx).stringify,
                   get_json_value(a_json_piece,indx),
                   a_parent_name,
                   a_access_path||'['||indx||']',
                   a_hierarchy_level,
                   indx,
                   get_json_type(l_array.get (indx)),
                   'array',
                   1
                   ); 
      case get_json_type(l_array.get (indx))
        when 'array' then
            traverse_array ( 
              treat (l_array.get (indx) as json_array_t), 
              l_array.get(indx).stringify,
              a_hierarchy_level + 1,
              a_access_path||'['||indx||']'
              ); 
        when 'object' then
            traverse_object( 
              treat (a_json_piece.get (indx) as json_object_t),
              l_array.get(indx).stringify,
              a_hierarchy_level+1,
              a_access_path||'['||indx||']'
              );
        else null;
      end case;
   end loop; 
  end traverse_array;
 
  member procedure init(self in out nocopy ut_json_tree_details,a_json_doc in json_element_t, a_level_in integer := 0) is
  begin
    if a_json_doc.is_object then
      traverse_object(treat (a_json_doc as json_object_t),null,1,'$');
    elsif a_json_doc.is_array then
      traverse_array(treat (a_json_doc as json_array_t),null,1,'$');
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
