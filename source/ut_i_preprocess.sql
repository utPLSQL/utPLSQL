COLUMN major NOPRINT NEW_VALUE major_v
COLUMN minor NOPRINT NEW_VALUE minor_v

--Get the major and minor versions

select major, SUBSTR(minor_version,1,instr(minor_version, '.')-1) minor
from
(
  select major, substr(version, length(major)+2) minor_version
  from
  (
    SELECT SUBSTR(version,1,instr(version, '.')-1) major, version
      FROM product_component_version p
    WHERE UPPER(PRODUCT) LIKE 'ORACLE%'
        OR UPPER(PRODUCT) LIKE 'PERSONAL ORACLE%'
  )
);

--Flags for 9.x code

COLUMN col NOPRINT NEW_VALUE start_ge_9

SELECT decode(greatest(8, &major_v), 8, '/* < v9 ', '/* >= v9 */') col  
FROM dual;

COLUMN col NOPRINT NEW_VALUE end_ge_9

SELECT decode(greatest(8, &major_v), 8, '< v9 */', '/* >= v9 */') col  
FROM dual;
      
COLUMN col NOPRINT NEW_VALUE start_lt_9

SELECT decode(greatest(8, &major_v), 8, '/* < v9 */', '/* >= v9 ') col  
FROM dual;

COLUMN col NOPRINT NEW_VALUE end_lt_9

SELECT decode(greatest(8, &major_v), 8, '/* < v9 */', ' >= v9 */') col  
FROM dual;

--Flags for 8.1 code

COLUMN col NOPRINT NEW_VALUE start_ge_8_1

SELECT decode(greatest(8, &major_v+(&minor_v/10)), 8, '/* < v8.1 ', '/* >= v8.1 */') col  
FROM dual;

COLUMN col NOPRINT NEW_VALUE end_ge_8_1

SELECT decode(greatest(8, &major_v+(&minor_v/10)), 8, ' < v8.1 */', '/* >= v8.1 */') col
FROM dual;
      
COLUMN col NOPRINT NEW_VALUE start_lt_8_1

SELECT decode(greatest(8, &major_v+(&minor_v/10)), 8, '/* < v8.1 */', '/* >= v8.1 ') col  
FROM dual;

COLUMN col NOPRINT NEW_VALUE end_lt_8_1

SELECT decode(greatest(8, &major_v+(&minor_v/10)), 8, '/* < v8.1 */', ' >= v8.1 */') col  
FROM dual;

--Flags for 8.x code

COLUMN col NOPRINT NEW_VALUE start_ge_8

SELECT decode(greatest(7, &major_v), 7, '/* < v8 ', '/* >= v8 */') col  
FROM dual;

COLUMN col NOPRINT NEW_VALUE end_ge_8

SELECT decode(greatest(7, &major_v), 7, ' < v8 */', '/* >= v8 */') col
FROM dual;
      
COLUMN col NOPRINT NEW_VALUE start_lt_8

SELECT decode(greatest(7, &major_v), 7, '/* < v8 */', '/* >= v8 ') col  
FROM dual;

COLUMN col NOPRINT NEW_VALUE end_lt_8

SELECT decode(greatest(7, &major_v), 7, '/* < v8 */', ' >= v8 */') col  
FROM dual;
