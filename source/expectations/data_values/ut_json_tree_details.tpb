create or replace type body ut_json_tree_details as

   member function get_json_type(a_json_piece json_element_t) return varchar2 is
   begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
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
    $else
      return null;
    $end
   end;
   
   member function get_json_value(a_json_piece json_element_t,a_key varchar2) return varchar2 is
     l_json_el json_element_t;
     l_val varchar2(4000);
   begin
   $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
     l_json_el := treat(a_json_piece as json_object_t).get (a_key);
     case 
       when l_json_el.is_string       then l_val := treat(a_json_piece as json_object_t).get_string(a_key);
       when l_json_el.is_number       then l_val := to_char(treat(a_json_piece as json_object_t).get_number(a_key));
       when l_json_el.is_boolean      then l_val := ut_utils.boolean_to_char(treat(a_json_piece as json_object_t).get_boolean(a_key));
       when l_json_el.is_true         then l_val := ut_utils.boolean_to_char(treat(a_json_piece as json_object_t).get_boolean(a_key));
       when l_json_el.is_false        then l_val := ut_utils.boolean_to_char(treat(a_json_piece as json_object_t).get_boolean(a_key));
       when l_json_el.is_date         then l_val := to_char(treat(a_json_piece as json_object_t).get_date(a_key),'DD/MM/RRRR');
       when l_json_el.is_timestamp then l_val := to_char(treat(a_json_piece as json_object_t).get_date(a_key),'DD/MM/RRRR HH24:MI:SS AM');
       else null;
      end case;
     return l_val;
    $else
      return null;
    $end
   end;
  
   member function get_json_value(a_json_piece json_element_t,a_key integer) return varchar2 is
     l_json_el json_element_t;
     l_val varchar2(4000);    
   begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
     l_json_el := treat(a_json_piece as json_array_t).get (a_key);
     case 
       when l_json_el.is_string       then l_val := treat(a_json_piece as json_array_t).get_string(a_key);
       when l_json_el.is_number       then l_val := to_char(treat(a_json_piece as json_array_t).get_number(a_key));
       when l_json_el.is_boolean      then l_val := ut_utils.boolean_to_char(treat(a_json_piece as json_array_t).get_boolean(a_key));
       when l_json_el.is_true         then l_val := ut_utils.boolean_to_char(treat(a_json_piece as json_array_t).get_boolean(a_key));
       when l_json_el.is_false        then l_val := ut_utils.boolean_to_char(treat(a_json_piece as json_array_t).get_boolean(a_key));
       when l_json_el.is_date         then l_val := to_char(treat(a_json_piece as json_array_t).get_date(a_key),'DD/MM/RRRR');
       when l_json_el.is_timestamp    then l_val := to_char(treat(a_json_piece as json_array_t).get_date(a_key),'DD/MM/RRRR HH24:MI:SS AM');
       else null;
      end case;
     return l_val;
    $else
      return null;
    $end
   end;  
      
   member procedure add_json_leaf(self in out nocopy ut_json_tree_details, a_element_name varchar2, a_element_value varchar2,
     a_parent_name varchar2, a_access_path varchar2, a_hierarchy_level integer, a_index_position integer, 
     a_json_type in varchar2, a_parent_type in varchar2, a_array_element integer := 0, a_parent_path varchar2) is
  begin
    self.json_tree_info.extend;
    self.json_tree_info(self.json_tree_info.last) := ut_json_leaf(a_element_name,a_element_value,a_parent_name,a_access_path,
      a_hierarchy_level, a_index_position,a_json_type, a_parent_type, a_array_element, a_parent_path);
  end;
  
  member procedure traverse_object(self in out nocopy ut_json_tree_details, a_json_piece json_element_t,
    a_parent_name varchar2 := null, a_hierarchy_level integer := 1, a_access_path varchar2 := null ) as
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    l_keys      json_key_list;
    l_object    json_object_t := treat(a_json_piece as json_object_t);
    $end
  begin
  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    l_keys := coalesce(l_object.get_keys,json_key_list()); 
    
    for indx in 1 .. l_keys.count
    loop           
          add_json_leaf(l_keys(indx),
                   get_json_value(l_object,l_keys(indx)),
                   a_parent_name,
                   a_access_path||'.'||l_keys(indx),
                   a_hierarchy_level,
                   indx,
                   get_json_type(l_object.get (l_keys(indx))),
                   'object',
                   0,
                   a_access_path
                   ); 
      case get_json_type(l_object.get(l_keys(indx)))
        when 'array' then
            traverse_array ( 
              treat (l_object.get (l_keys(indx)) as json_array_t), 
              l_keys(indx),
              a_hierarchy_level + 1,
              a_access_path||'.'||l_keys(indx)
              ); 
        when 'object' then
            traverse_object( treat (l_object.get (l_keys(indx)) as json_object_t),
              l_keys (indx),
              a_hierarchy_level+1,
              a_access_path||'.'||l_keys(indx)
              );
        else null;      
      end case;
   end loop; 
  $else
      null;
  $end
  end traverse_object;
 
  member procedure traverse_array(self in out nocopy ut_json_tree_details, a_json_piece json_element_t, 
     a_parent_name varchar2 := null, a_hierarchy_level integer := 1, a_access_path varchar2 := null ) as
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    l_array     json_array_t;
    $end
    l_type      varchar2(50);
    l_name      varchar2(4000); 
  begin
  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    l_array  := treat(a_json_piece as json_array_t);
    for indx in 0 .. l_array.get_size - 1 
    loop 
      l_type := get_json_type(l_array.get (indx));
      l_name := case when l_type = 'object' then l_type else l_array.get(indx).stringify end;
           
           add_json_leaf(l_name,
                   get_json_value(a_json_piece,indx),
                   a_parent_name,
                   a_access_path||'['||indx||']',
                   a_hierarchy_level,
                   indx,
                   l_type,
                   'array',
                   1,
                   a_access_path
                   ); 
      case l_type
        when 'array' then
            traverse_array ( 
              treat (l_array.get (indx) as json_array_t), 
              l_name,
              a_hierarchy_level + 1,
              a_access_path||'['||indx||']'
              ); 
        when 'object' then
            traverse_object( 
              treat (l_array.get (indx) as json_object_t),
              l_name,
              a_hierarchy_level+1,
              a_access_path||'['||indx||']'
              );
        else null;
      end case;
   end loop; 
  $else
      null;
  $end
  end traverse_array;
 
  member procedure init(self in out nocopy ut_json_tree_details,a_json_doc in json_element_t, a_level_in integer := 0) is
  begin
  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    if a_json_doc.is_object then
      traverse_object(treat (a_json_doc as json_object_t),null,1,'$');
    elsif a_json_doc.is_array then
      traverse_array(treat (a_json_doc as json_array_t),null,1,'$');
    end if;  
  $else
      null;
  $end
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
