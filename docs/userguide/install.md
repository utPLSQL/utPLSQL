# Installation

To simply install the utPLSQL into a new database schema and grant it to public, execute the script `install_headless.sql`.

This will create a new user `UT3` with password `UT3`, grant all needed privileges to that user and create PUBLIC synonyms needed tu sue the utPLSQL framework.

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@install_headless.sql  
```


#Recommended Schema
It is recommended to install utPLSQL in it's own schema. You are free to choose any name for this schema.

The installation user/schema must have the following Oracle system permissions during the installation.
  - CREATE SESSION
  - CREATE PROCEDURE
  - CREATE TYPE
  - CREATE TABLE
  - CREATE SYNONYM
  - ALTER SESSION
  
In addition it must be granted execute to the following system packages.

  - DBMS_PIPE  
  
# Installation Procedure


### Creating schema for utPLSQL
To create the utPLSQL schema and grant all the needed privileges execute script `create_utplsql_owner.sql` from the `source` directory with parameters:
- `user name` - the name of the user that will own of utPLSQL object
- `password`  - the password to be set for that user
- `tablespace name` - the tablespace name to hold data created during test execution

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@create_utPLSQL_owner.sql ut3 ut3 users  
```

### Installing utPLSQL
To install the utPLSQL sources into your database run the `/source/install.sql` script and provide the `schema name` where utPLSQL is to be installed  
You need to install the utPLSQL sources into a already existing database schema.
You may install it from any account that has sufficient privileges to create objects in other users schema.
You may also choose to install it directly into the schema owning the package.  

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@install.sql ut3  
```

### Allowing other users to access utPLSQL framework
In order to allow other users to access utPLSQL, synonyms must be created and grants need to be added.
You have two options:
- use public grants and synonyms, to allow any user to access the framework
- use synonyms and grants for individual users to limit the access the the framework
 
To grant utPLSQL to public execute the script `source/create_synonyms_and_grants_for_public.sql` and provide the provide `schema name` where utPLSQL is installed 

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@create_synonyms_and_grants_for_public.sql ut3  
```
To grant utPLSQL to individual user execute the script `source/create_synonyms_and_grants_for_user.sql` and provide provide the `schema name` where utPLSQL is installed and `user name` to be granted

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@create_synonyms_and_grants_for_user.sql ut3 hr  
```

The following tools that support the SQL*Plus commands can be used to run the installation script
  - SQL*Plus
  - [SQLcl](http://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html)
  - [Oracle SQL Developer](http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html)
 

# Uninstalling utPLSQL

To uninstall run `/source/uninstall.sql` and provide the provide `schema name` where utPLSQL is installed.

The uninstall script will remove all the objects installed by the install script.
Additionally, all the public and private synonyms pointing to the objects in utPLSQL schema will be removed.

If you have you have extended any utPLSQL types such as a custom reporter, these will need to be dropped before the uninstall, otherwise the uninstall script might fail.

In order for the uninstall to be successful, you need to use the uninstall script, that was provided wht the exact version that was installed on your database.
