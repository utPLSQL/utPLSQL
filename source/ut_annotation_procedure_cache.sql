create table ut_annotation_procedure_cache (
  owner                  varchar2(30)   not null,
  package_name           varchar2(30)   not null,
  procedure_name         varchar2(30)   not null,
  annotation_name        varchar2(30)   not null,
  annotation_param_key   varchar2(1000),
  annotation_param_value varchar2(1000),
  constraint ut_annotation_proc_cache_pk primary key(owner, package_name, procedure_name, annotation_name),
  constraint ut_annotation_proc_cache_fk foreign key(owner, package_name) references ut_annotation_package_info(owner, package_name) on delete cascade
);

create index ut_annotation_proc_cache_fk on ut_annotation_procedure_cache(owner, package_name);
