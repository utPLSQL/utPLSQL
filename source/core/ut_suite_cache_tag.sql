create table ut_suite_cache_tag (
 suiteid           number(22) not null,
 tagname           varchar2(100) not null,
 constraint ut_suite_to_tag_pk primary key (suiteid,tagname),
 constraint ut_suite_id_fk foreign key ( suiteid ) references ut_suite_cache(id) on delete cascade
)
organization index;