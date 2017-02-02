create global temporary table ut_coverage_sources_tmp(
owner varchar2(250),
name  varchar2(250),
line  number(38,0),
text varchar2(4000),
constraint ut_coverage_sources_tmp primary key (owner,name,line)
) on commit preserve rows;
