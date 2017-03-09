#Creating a release

To build a new release from a branch of utPLSQL project do the following:

- Decide on the version number to be created follow the [semantic versioning](http://semver.org/)
- Create a new branch named in one of the following formats:
   - `release/vMAJOR.MINOR.PATCH`
   - `release/vMAJOR.MINOR.PATCH-alpha`
   - `release/vMAJOR.MINOR.PATCH-beta`
   - `release/vMAJOR.MINOR.PATCH-something`

The naming convention is there to instruct Travis to do a release from build on that branch.

Version to be built is extracted from the branch name.

The list of project files to be excluded from a release is controlled by content of `.gitattributes` file.


#The Release build

Release build is performing all the activities of regular build and additionally dose the following:
- Cleans the working copy
- Updates all project files with new version number 
- Generates html documentation
- Commits and pushes
- Creates a release tag and publishes the release artifacts
- Removes generated documentation
- Commits and pushes


#Post release tasks

Once the release is published, it is recommended to merge it to the develop branch and delete it after.
