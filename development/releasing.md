The release process is semi-automated.

With every build, the build process on Travis updates files with an appropriate version number before deployment into the database.
This step is performed, to confirm that the update of versions works properly.

To create a release:
   - create release branch and wait for release build to complete successfully
   - merge release branch to master and wait for master build to complete successfully
   - create a release from the master branch using github web page and populate release description using information found on the issues and pull requests for release 

The following will happen:
   - build executed on branch `release/v1.2.3-[something]` updates files `sonar-project.properties`, `VERSION` with project version derived from the release branch name
   - changes to those two files are committed and pushed back to release branch by Travis
   - when a release is created, a new tag is added in on the repository and a tag build is executed
   - the documentation for new release is published on `utplsql.github.io` and installation archives are added to the tag.

Note:
The released version does not provide access to un-versioned source files (the default zip file from GitHub is empty). 
The sources for release are provided in separate zip files delivered from the Travis build process.
This is because we do not keep version in our source files in develop branch.
