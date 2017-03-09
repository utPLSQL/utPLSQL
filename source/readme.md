# utPLSQL sources 

The sources to be installed on the database.

To simply install the utPLSQL into a new database schema and grant it to public, execute the script `install_headless.sql`.

This will create a new user `UT3` with password `UT3`, grant all needed privileges to that user and create PUBLIC synonyms needed tu sue the utPLSQL framework.

Example invocation of the script from command line:
```bash
cd source
sqlplus admin/admins_password@xe @@install_headless.sql  
```

For detailed instructions on other install options see the [Install Guide](../docs/md/userguide/install.md)
