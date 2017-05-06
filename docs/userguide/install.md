# Downloading latest version of utPLSQL

It is quite easy to download latest version of utPLSQL from github on Unix machines.
Here is a little snippet that can be handy for downloading latest version.  
```bash
#!/bin/bash
# Get the url to latest release "zip" file
UTPLSQL_DOWNLOAD_URL=$(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip" | sed 's/"//g')
# Extract file name from the URL 
UTPLSQL_DOWNLOAD_FILE="${UTPLSQL_DOWNLOAD_URL##*/}"
# Extract the output directory from URL
UTPLSQL_DIR="${UTPLSQL_DOWNLOAD_FILE%.*}"
# Download the latest utPLSQL release "zip" file
curl -LOk "${UTPLSQL_DOWNLOAD_URL}"
# Extract downloaded "zip" file
unzip -q "${UTPLSQL_DOWNLOAD_FILE}"
```

You may download with a one-liner if that is more convenient.
```bash
#!/bin/bash
curl -LOk $(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip" | sed 's/"//g') 
```

# Installation

To simply install the utPLSQL into a new database schema and grant it to public, execute the script `install_headless.sql`.

This will create a new user `UT3` with password `UT3`, grant all needed privileges to that user and create PUBLIC synonyms needed to sue the utPLSQL framework.

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@install_headless.sql  
```


# Recommended Schema
It is recommended to install utPLSQL in it's own schema. You are free to choose any name for this schema.

The installation user/schema must have the following Oracle system permissions during the installation.
  - CREATE SESSION
  - CREATE PROCEDURE
  - CREATE TYPE
  - CREATE TABLE
  - CREATE VIEW
  - CREATE SYNONYM
  - ALTER SESSION
  
In addition it must be granted execute to the following system packages.

  - DBMS_LOCK
    
The utPLSQL is using Oracle [DBMS_PROFILER tables](https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_profil.htm#i999476). The tables will be created in the installation schema if they do not exist.
The uninstall process however will not drop those tables, as they can potentially be shared and reused for profiling PLSQL code.
It is up to DBA to maintain the storage of the profiler tables.

  
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
 
# Additional requirements

In order to use Code Coverage functionality of utPLSQL users executing the tests must have the CREATE privilege on the PLSQL code that the coverage is gathered on.
This is a requirement of [DBMS_PROFILER package](https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_profil.htm#i999476).

In practice, user running tests for PLSQL code that he does not own, needs to have CREATE ANY PROCEDURE/CREATE ANY TRIGGER privileges.
Running code coverage on objects that the user does not own will not produce any coverage information without those privileges.

# Uninstalling utPLSQL

To uninstall run `/source/uninstall.sql` and provide the provide `schema name` where utPLSQL is installed.

The uninstall script will remove all the objects installed by the install script.
Additionally, all the public and private synonyms pointing to the objects in utPLSQL schema will be removed.

If you have you have extended any utPLSQL types such as a custom reporter, these will need to be dropped before the uninstall, otherwise the uninstall script might fail.

In order for the uninstall to be successful, you need to use the uninstall script, that was provided wht the exact version that was installed on your database.
