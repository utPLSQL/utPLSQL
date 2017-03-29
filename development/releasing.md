Release process is automated in following way:
1) with every build, the build process on travis updatse files with appropriate version number before deployment into db.
   This is to confirm that the update of versions works properly.
2) when build is executed on a branch named `release/v1.2.3-something` then additional steps are taken:
    - project version in files: `sonar-project.properties`, `VERSION` is updated from the version number derived from release branch
    - changes on those two files are committed and and pushed - this should happen only once, when the release branch is initially created on the main repo
3) To create a release, just create a tag on the code to be released. The tag name must match the regex pattern: `^v[0-9]+\.[0-9]+\.[0-9]+.*$`
   - When a tag build is executed, the documentation is built and files are uploaded to the tag.
   - The version number is derived from the tag name.
4) Release version do not provide access to unversioned source files (the default zip file from github is empty). 
   The sources for release are provided in separate zip files delivered from travis build process.
