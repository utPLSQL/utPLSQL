BEGIN

  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    dbms_output.put_line('Object exists , dont install');
  $else
    dbms_output.put_line('Installing json structures specs.');
    execute immediate  q'[create or replace TYPE JSON_Element_T FORCE AUTHID CURRENT_USER AS OBJECT(
   dummyobjt NUMBER,
   STATIC FUNCTION  parse(jsn VARCHAR2) RETURN JSON_Element_T,
   STATIC FUNCTION  parse(jsn CLOB) RETURN JSON_Element_T,
   STATIC FUNCTION  parse(jsn BLOB) RETURN JSON_Element_T,
   MEMBER FUNCTION  to_Clob(self IN JSON_ELEMENT_T)      RETURN CLOB,
   MEMBER FUNCTION  stringify(self IN JSON_ELEMENT_T)   RETURN VARCHAR2,
   MEMBER FUNCTION  is_Object(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_Array(self IN JSON_ELEMENT_T)      RETURN BOOLEAN,
   MEMBER FUNCTION  is_Scalar(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_String(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_Number(self IN JSON_ELEMENT_T)     RETURN BOOLEAN,
   MEMBER FUNCTION  is_Boolean(self IN JSON_ELEMENT_T)    RETURN BOOLEAN,
   MEMBER FUNCTION  is_True(self IN JSON_ELEMENT_T)       RETURN BOOLEAN,
   MEMBER FUNCTION  is_False(self IN JSON_ELEMENT_T)      RETURN BOOLEAN,
   MEMBER FUNCTION  is_Null(self IN JSON_ELEMENT_T)       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Date(self IN JSON_ELEMENT_T)       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Timestamp(self IN JSON_ELEMENT_T)  RETURN BOOLEAN,

   MEMBER FUNCTION  get_Size(self IN JSON_ELEMENT_T) RETURN NUMBER
) NOT FINAL NOT INSTANTIABLE;]';

    execute immediate  q'[create or replace TYPE JSON_KEY_LIST FORCE AS VARRAY(32767) OF VARCHAR2(4000);]';
    
    execute immediate  q'[create or replace TYPE JSON_Array_T FORCE AUTHID CURRENT_USER
                       UNDER JSON_Element_T(
   dummy NUMBER,
   CONSTRUCTOR FUNCTION JSON_Array_T(self IN OUT JSON_ARRAY_T)
                        RETURN SELF AS RESULT,

   MEMBER      FUNCTION  get(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN JSON_Element_T,
   MEMBER      FUNCTION  get_String(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Number(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN NUMBER,
   MEMBER      FUNCTION  get_Boolean(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN BOOLEAN,
   MEMBER      FUNCTION  get_Date(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN DATE,
   MEMBER      FUNCTION  get_Timestamp(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN TIMESTAMP,
   MEMBER      FUNCTION  get_Clob(self IN JSON_ARRAY_T, pos NUMBER) RETURN CLOB,
   MEMBER      PROCEDURE get_Clob(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER,
                                  c IN OUT NOCOPY CLOB),
   MEMBER      FUNCTION  get_Blob(self IN JSON_ARRAY_T, pos NUMBER) RETURN BLOB,
   MEMBER      PROCEDURE get_Blob(self IN OUT NOCOPY JSON_ARRAY_T, pos NUMBER,
                                  b IN OUT NOCOPY BLOB),
   MEMBER      FUNCTION  get_Type(self IN JSON_ARRAY_T, pos NUMBER)
                         RETURN VARCHAR2
) FINAL;]';
    
    execute immediate  q'[create or replace TYPE JSON_Object_T AUTHID CURRENT_USER UNDER JSON_Element_T(
   dummy NUMBER,
   CONSTRUCTOR FUNCTION JSON_Object_T(self IN OUT JSON_OBJECT_T)
                        RETURN SELF AS RESULT,
 
   MEMBER      FUNCTION  get(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN JSON_Element_T,
   MEMBER      FUNCTION  get_Object(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN JSON_OBJECT_T,
   MEMBER      FUNCTION  get_Array(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN JSON_ARRAY_T,
   MEMBER      FUNCTION  get_String(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Number(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN NUMBER,
   MEMBER      FUNCTION  get_Boolean(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN BOOLEAN,
   MEMBER      FUNCTION  get_Date(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN DATE,
   MEMBER      FUNCTION  get_Timestamp(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN TIMESTAMP,
   MEMBER      FUNCTION  get_Clob(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN CLOB,
   MEMBER      PROCEDURE get_Clob(self IN OUT NOCOPY JSON_OBJECT_T,
                                  key VARCHAR2, c IN OUT NOCOPY CLOB),
   MEMBER      FUNCTION  get_Blob(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN BLOB,
   MEMBER      PROCEDURE get_Blob(self IN OUT NOCOPY JSON_OBJECT_T,
                                 key VARCHAR2, b IN OUT NOCOPY BLOB),
   MEMBER      FUNCTION  get_Type(self IN JSON_OBJECT_T, key VARCHAR2)
                         RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Keys(self IN JSON_OBJECT_T) RETURN JSON_KEY_LIST
) FINAL;]';
  $end

END;
/