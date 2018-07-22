The release process is semi-automated.

With every build, the build process on Travis updates files with an appropriate version number before deployment into the database.
This step is performed, to confirm that the update of versions works properly.

To create a release:
   - create release branch from development branch and make sure to name the release branch: `release/vX.Y.Z`
   - update, commit and push at least one file change in the release branch, to kickoff a Travis build
   - wait for th build to complete successfully
   - merge the release branch to master and wait for master build to complete successfully
   - create a release from the master branch using [github releases page](https://github.com/utPLSQL/utPLSQL/releases) and populate release description using information found on the issues and pull requests since previous release.
   To find issues closed after certain date use [advanced filters](https://help.github.com/articles/searching-issues-and-pull-requests/#search-by-open-or-closed-state) 

The following will happen:
   - build executed on branch `release/vX.Y.Z-[something]` updates files `sonar-project.properties`, `VERSION` with project version derived from the release branch name
   - changes to those two files are committed and pushed back to release branch by Travis
   - when a release is created, a new tag is added in on the repository and a tag build is executed
   - the documentation for new release is published on `utplsql.github.io` and installation archives are added to the tag.

Note:
The sources for release are provided in separate zip files delivered from the Travis build process.
The built zip files include HTML documentation generated from MD files.
