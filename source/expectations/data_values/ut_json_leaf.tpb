create or replace type body ut_json_leaf as
   
   member procedure init( self in out nocopy ut_json_leaf,
     a_element_name varchar2, a_element_value varchar2,a_parent_name varchar2,
     a_access_path varchar2, a_hierarchy_level integer, a_index_position integer, a_json_type in varchar2,
     a_parent_type varchar2, a_array_element integer:=0) is
   begin
      self.element_name     := a_element_name;
      self.element_value    := a_element_value;
      self.parent_name      := a_parent_name;
      self.hierarchy_level  := a_hierarchy_level;
      self.access_path      := a_access_path;      
      self.index_position   := a_index_position;
      self.json_type        := a_json_type;
      self.is_array_element := a_array_element;
      self.parent_type      := a_parent_type;
   end;
     
   constructor function ut_json_leaf( self in out nocopy ut_json_leaf,
     a_element_name varchar2, a_element_value varchar2,a_parent_name varchar2,
     a_access_path varchar2, a_hierarchy_level integer, a_index_position integer, a_json_type in varchar2,
     a_parent_type varchar2, a_array_element integer:=0)
   return self as result is
   begin
     init(a_element_name,a_element_value,a_parent_name, a_access_path, a_hierarchy_level, a_index_position, 
       a_json_type,a_parent_type,a_array_element);
   return;
   end;

end;
/
