create table ut_annotation_package_cache (
  owner                         varchar2(30)   not null,
  package_name                  varchar2(30)   not null,
  procedure_name                varchar2(30),
  annotation_name               varchar2(1000) not null,
  annotation_param_pos          number(3,0),
  annotation_param_key          varchar2(255),
  annotation_param_value        varchar2(1000),
  not_null_annotation_param_pos number(3,0)    not null,
  not_null_procedure_name       varchar2(30)   not null,
  constraint ut_annotation_package_cache_c1 check ( not_null_annotation_param_pos = nvl(annotation_param_pos, 0) ),
  constraint ut_annotation_package_cache_c2 check ( not_null_procedure_name = nvl(procedure_name, 'null') ),
  constraint ut_annotation_package_cache_pk primary key(owner, package_name, not_null_procedure_name, annotation_name, not_null_annotation_param_pos),
  constraint ut_annotation_package_cache_fk foreign key(owner, package_name) references ut_annotation_package_info(owner, package_name) on delete cascade
) organization index;

create index ut_annotation_package_cache_fk on ut_annotation_package_cache(owner, package_name);
