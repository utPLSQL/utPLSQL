create or replace type body ut_cursor_column as
   
   member procedure init(
     self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type varchar2, a_collection integer,a_access_path in varchar2
   ) is
   begin
      self.parent_name      := a_parent_name; --Name of the parent if its nested
      self.hierarchy_level  := a_hierarchy_level; --Hierarchy level
      self.column_position  := a_col_position; --Position of the column in cursor/ type
      self.column_len       := a_col_max_len; --length of column
      self.column_name      := TRIM( BOTH '''' FROM a_col_name); --name of the column
      self.column_type_name := coalesce(a_col_type_name,a_col_type); --type name e.g. test_dummy_object or varchar2
      self.xml_valid_name   := ut_utils.get_valid_xml_name(self.column_name);
      self.display_path     := case when a_access_path is null then 
                                 self.column_name 
                               else 
                                 a_access_path||'/'||self.column_name 
                               end; --Access path used for incldue exclude eg/ TEST_DUMMY_OBJECT/VARCHAR2       
      self.access_path      := case when a_access_path is null then 
                                 self.xml_valid_name 
                               else 
                                 a_access_path||'/'||self.xml_valid_name 
                               end; --Access path used for incldue exclude eg/ TEST_DUMMY_OBJECT/VARCHAR2     
      self.transformed_name := case when length(self.xml_valid_name) > 30 then
                                 '"'||ut_compound_data_helper.get_fixed_size_hash(self.parent_name||self.xml_valid_name)||'"'
                               when self.parent_name is null then 
                                 '"'||self.xml_valid_name||'"'
                               else 
                                 '"'||ut_compound_data_helper.get_fixed_size_hash(self.parent_name||self.xml_valid_name)||'"'
                               end; --when is nestd we need to hash name to make sure we dont exceed 30 char
      self.column_type      := a_col_type; --column type e.g. user_defined , varchar2
      self.column_schema    := a_col_schema_name; -- schema name
      self.is_sql_diffable  := case 
                              when lower(self.column_type) = 'user_defined_type' then 
                                0 
                              -- Due to bug in 11g/12.1 collection fails on varchar 4000+
                              when (lower(self.column_type) in ('varchar2','char')) and (self.column_len > 4000) then
                                0
                              else 
                                ut_utils.boolean_to_int(ut_compound_data_helper.is_sql_compare_allowed(self.column_type))
                              end;  --can we directly compare or do we need to hash value
      self.is_collection   := a_collection;
      self.has_nested_col := case when lower(self.column_type) = 'user_defined_type' and self.is_collection = 0 then 1 else 0 end;
   end;
     
   constructor function ut_cursor_column( self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type in varchar2, a_collection integer,a_access_path in varchar2
   ) return self as result is
   begin
     init(a_col_name, a_col_schema_name, a_col_type_name, a_col_max_len, a_parent_name,a_hierarchy_level, a_col_position, a_col_type, a_collection,a_access_path);
   return;
   end;
   
   constructor function ut_cursor_column( self in out nocopy ut_cursor_column) return self as result is
   begin
     return;
   end;
end;
/
