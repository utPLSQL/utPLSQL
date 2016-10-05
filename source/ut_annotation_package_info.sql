create table ut_annotation_package_info (
  owner           varchar2(30) not null,
  package_name    varchar2(30) not null,
  parse_timestamp timestamp    not null,
  is_annotated    varchar2(1)  not null,
  constraint ut_annotation_package_info_pk primary key(owner, package_name)
) organization index;
