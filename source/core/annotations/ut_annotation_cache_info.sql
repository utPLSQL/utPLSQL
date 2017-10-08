create table ut_annotation_cache_info (
  cache_id        number(20,0)  not null,
  object_owner    varchar2(250) not null,
  object_name     varchar2(250) not null,
  object_type     varchar2(250) not null,
  parse_time      date          not null,
  is_annotated    varchar2(1)   not null,
  constraint ut_annotation_cache_info_pk primary key(cache_id),
  constraint ut_annotation_cache_info_uk unique (object_owner, object_name, object_type),
  constraint ut_annotation_cache_info_ck1 check (is_annotated in ('Y','N'))
) organization index;

