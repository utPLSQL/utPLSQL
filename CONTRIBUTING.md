## How to contribute ##

The following are the guidelines, everyone should use to contribute to utPLSQL.  
Changes are welcome from all members of the Community. 

## Getting Started ##

1. Create a [GitHub Account](https://github.com/join).
2. Fork the utPLSQL Repository and setup your local Repository.
     * Each of the steps below are detailed in the [How to Fork](https://help.github.com/articles/fork-a-repo) article!
     * Clone your Fork to your local machine.
     * Configure "upstream" remote to the [master utPLSQL repository](https://github.com/utPLSQL/utPLSQL.git).
3. For each change you want to make:       
     * Create a new branch for your change. 
     * Make your change in your new branch. 
         * Although changes can be made in the master branch, it easier long term if a new branch is used.
     * **Verify code compiles and unit tests still pass.** 
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
	* Arguments to procedures and functions will start with `a_` an Example would be procedure `is_valid(a_owner_name varchar2(30));`
	* Object types and packages will start with `ut_`
	* Local variables `l_`
	* Global variables `g_`
	* Global Constants start with `gc_`
	* Types in packages, objects start with `t_`
	* Nested Tables start with `tt_`
* varchar2 lengths are set in characters not bytes 

 
## New to GIT ##

If you are new to GIT here are some links to help you with understanding how it works.    

- [GIT Documentation](http://git-scm.com/doc)
- [Atlassian Git Tutorial](https://www.atlassian.com/git/tutorial/git-basics)
- [What are other resources for learning Git and GitHub](https://help.github.com/articles/what-are-other-good-resources-for-learning-git-and-github) 
