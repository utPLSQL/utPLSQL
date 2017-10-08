create table ut_annotation_cache (
  cache_id                      number(20,0)   not null,
  annotation_position           number(5,0)    not null,
  annotation_name               varchar2(1000) not null,
  annotation_text               varchar2(4000),
  subobject_name                varchar2(250),
--   subobject_name_not_null       varchar2(250) generated always as (nvl(subobject_name,'null')) not null,
  constraint ut_annotation_cache_pk primary key(cache_id, annotation_position),
--   constraint ut_annotation_cache_pk primary key(cache_id, annotation_position, subobject_name_not_null),
  constraint ut_annotation_cache_fk foreign key(cache_id) references ut_annotation_cache_info(cache_id) on delete cascade
);

create index ut_annotation_cache_fk on ut_annotation_cache(cache_id);

