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
   MEMBER FUNCTION  to_Clob         RETURN CLOB,
   MEMBER FUNCTION  stringify       RETURN VARCHAR2,
   MEMBER FUNCTION  is_Object       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Array        RETURN BOOLEAN,
   MEMBER FUNCTION  is_Scalar       RETURN BOOLEAN,
   MEMBER FUNCTION  is_String       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Number       RETURN BOOLEAN,
   MEMBER FUNCTION  is_Boolean      RETURN BOOLEAN,
   MEMBER FUNCTION  is_True         RETURN BOOLEAN,
   MEMBER FUNCTION  is_False        RETURN BOOLEAN,
   MEMBER FUNCTION  is_Null         RETURN BOOLEAN,
   MEMBER FUNCTION  is_Date         RETURN BOOLEAN,
   MEMBER FUNCTION  is_Timestamp    RETURN BOOLEAN,
   MEMBER FUNCTION  to_string       RETURN VARCHAR2,
   MEMBER FUNCTION  to_number       RETURN NUMBER,
   MEMBER FUNCTION  to_boolean      RETURN BOOLEAN,
   MEMBER FUNCTION  to_date         RETURN VARCHAR2,

   MEMBER FUNCTION  get_Size(self IN JSON_ELEMENT_T) RETURN NUMBER
) NOT FINAL NOT INSTANTIABLE;]';

    execute immediate  q'[create or replace TYPE JSON_KEY_LIST FORCE AS VARRAY(32767) OF VARCHAR2(4000);]';
    
    execute immediate  q'[create or replace TYPE JSON_Array_T FORCE AUTHID CURRENT_USER UNDER JSON_Element_T(
   CONSTRUCTOR FUNCTION JSON_Array_T RETURN SELF AS RESULT,
   MEMBER      FUNCTION  get(pos NUMBER) RETURN JSON_Element_T,
   MEMBER      FUNCTION  get_String(pos NUMBER) RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Number(pos NUMBER) RETURN NUMBER,
   MEMBER      FUNCTION  get_Boolean(pos NUMBER) RETURN BOOLEAN,
   MEMBER      FUNCTION  get_Date(pos NUMBER) RETURN DATE,
   MEMBER      FUNCTION  get_Timestamp(pos NUMBER) RETURN TIMESTAMP,
   MEMBER      FUNCTION  get_Clob(pos NUMBER) RETURN CLOB,
   MEMBER      PROCEDURE get_Clob(pos NUMBER, c IN OUT NOCOPY CLOB),
   MEMBER      FUNCTION  get_Blob(pos NUMBER) RETURN BLOB,
   MEMBER      PROCEDURE get_Blob(pos NUMBER,   b IN OUT NOCOPY BLOB),
   MEMBER      FUNCTION  get_Type(pos NUMBER) RETURN VARCHAR2
) FINAL;]';
    
    execute immediate  q'[create or replace TYPE JSON_Object_T AUTHID CURRENT_USER UNDER JSON_Element_T(
   CONSTRUCTOR FUNCTION JSON_Object_T RETURN SELF AS RESULT,
   MEMBER      FUNCTION  get(key VARCHAR2) RETURN JSON_Element_T,
   MEMBER      FUNCTION  get_Object(key VARCHAR2) RETURN JSON_OBJECT_T,
   MEMBER      FUNCTION  get_Array(key VARCHAR2) RETURN JSON_ARRAY_T,
   MEMBER      FUNCTION  get_String(key VARCHAR2) RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Number(key VARCHAR2) RETURN NUMBER,
   MEMBER      FUNCTION  get_Boolean(key VARCHAR2) RETURN BOOLEAN,
   MEMBER      FUNCTION  get_Date(key VARCHAR2) RETURN DATE,
   MEMBER      FUNCTION  get_Timestamp(key VARCHAR2) RETURN TIMESTAMP,
   MEMBER      FUNCTION  get_Clob(key VARCHAR2) RETURN CLOB,
   MEMBER      PROCEDURE get_Clob(key VARCHAR2, c IN OUT NOCOPY CLOB),
   MEMBER      FUNCTION  get_Blob(key VARCHAR2) RETURN BLOB,
   MEMBER      PROCEDURE get_Blob(key VARCHAR2, b IN OUT NOCOPY BLOB),
   MEMBER      FUNCTION  get_Type(key VARCHAR2) RETURN VARCHAR2,
   MEMBER      FUNCTION  get_Keys RETURN JSON_KEY_LIST
) FINAL;]';
  $end

END;
/