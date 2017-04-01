## How to contribute ##

The following are the guidelines, everyone should use to contribute to utPLSQL.  
Changes are welcome from all members of the Community. 

## Getting Started ##

1. Create a [GitHub Account](https://github.com/join).
2. Fork the utPLSQL Repository and setup your local Repository.
     * Each of the steps below are detailed in the [How to Fork](https://help.github.com/articles/fork-a-repo) article!
     * Clone your Fork to your local machine.
     * Configure "upstream" remote to the [master utPLSQL repository](https://github.com/utPLSQL/utPLSQL.git).
     * Update the git submodules by issuing command: [git submodule update --remote --merge](http://stackoverflow.com/a/21195182)
3. For each change you want to make:       
     * Create a new branch for your change. 
     * Make your change in your new branch. 
         * Although changes can be made in the master branch, it easier long term if a new branch is used.
     * Make sure your change is covered with unit tests and/or is represented in examples
     * **Verify code compiles and all existing and new unit tests pass.**
         * The quickest way to have a Pull Request not be accepted, is to submit code that does not compile or pass tests.
     * Commit change to your local repository.
     * Push change to your remote repository
     * Submit a [Pull Request](https://help.github.com/articles/using-pull-requests).
     * Note: local and remote branches can be deleted after pull request has been accepted.

**Note:** Getting changes from others requires [Syncing your Local repository](https://help.github.com/articles/syncing-a-fork) with Master utPLSQL repository.    This can happen at any time.


## Coding Standards ##

* Snake case will be used.   This separates keywords in names with underscores.  `execute_test`
* All names will be lower case.
* Prefixes:
	* Arguments to procedures and functions will start with `a_` an Example would be procedure `is_valid(a_owner_name varchar2);`
	* Object types and packages will start with `ut_`
	* Local variables `l_`
	* Global variables `g_`
	* Global Constants start with `gc_`
	* Types in packages, objects start with `t_`
	* Nested Tables start with `tt_`
* varchar2 lengths are set in characters not bytes 


## Testing Environment ##

We are using docker images to test utPLSQL on our Travis CI builds. The following versions of Oracle Database are being used.

* 11g XE R2
* 12c SE R1
* 12c SE R2

These images are based on the official dockerfiles released by Oracle, but due to licensing restrictions, we can't make the images public. You can build your own and use it locally, or push to a private docker repository.

The build steps are simple if you already have some experience using Docker. You can find detailed information about how to build your own image with a running database in: [example of creating an image with pre-built DB](https://github.com/oracle/docker-images/blob/master/OracleDatabase/samples/prebuiltdb/README.md)

> You can find more info about the official Oracle images on the [Oracle Database on Docker](https://github.com/oracle/docker-images/tree/master/OracleDatabase) GitHub page.

> If you are new to Docker, you can start by reading the [Getting Started With Docker](https://docs.docker.com/engine/getstarted/) docs.

### Build Notes ###
* You may not forget to comment out the VOLUME line. This step is required, because VOLUMES are not saved using `docker commit` command.

* When the build proccess is complete, you will run the container to install the database. Once everything is set up and you see the message "DATABASE IS READY!", you may change the password and stop the running container. After the container is stopped, you can safely commit the container.

* You can use the --squash experimental docker tag to reduce the image size. Example:
```
docker build --force-rm --no-cache --squash -t oracle/db-prebuilt .
```

Travis will use your Docker Hub credentials to pull the private images, and the following secure environment variables must be defined.

Variable | Description
---------|------------
**DOCKER_USER** **DOCKER_PASSWORD** | _Your Docker Hub website credentials. They will be used to pull the private database images._

### SQLCL ###

Our build configurarion uses SQLCL to run the scripts, and you need to configure a few additional secure environment variables. After the first build, the downloaded file will be cached.

Variable | Description
---------|------------
**ORACLE_OTN_USER ORACLE_OTN_PASSWORD** | _Your Oracle website credentials. They will be used to download SQLCL._


## New to GIT ##

If you are new to GIT here are some links to help you with understanding how it works.    

- [GIT Documentation](http://git-scm.com/doc)
- [Atlassian Git Tutorial](https://www.atlassian.com/git/tutorial/git-basics)
- [What are other resources for learning Git and GitHub](https://help.github.com/articles/what-are-other-good-resources-for-learning-git-and-github) 
