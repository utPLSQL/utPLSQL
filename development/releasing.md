## Release process 

To create a release follow the below steps

## Release preparation
   - Create a **draft** of a Release with version number `vX.Y.X`  sourced from the `main` branch using [github releases page](https://github.com/utPLSQL/utPLSQL/releases) and populate release description using information found on the issues and pull requests **since previous release**.
   To find issues closed after certain date use [advanced filters](https://help.github.com/articles/searching-issues-and-pull-requests/#search-by-open-or-closed-state). 
   Example: [`is:issue closed:>2018-07-22`](https://github.com/utPLSQL/utPLSQL/issues?utf8=%E2%9C%93&q=is%3Aissue+closed%3A%3E2018-07-22+)

## Performing a release
   - create the release branch from `develop` branch and make sure to name the release branch: `release/vX.Y.Z`
   - update, commit and push at least one file change in the release branch, to kick off a build on [GithubActions](https://github.com/utPLSQL/utPLSQL/actions) or kick-off a build manually for that branch after it was created on github. 
   - wait for the build to complete successfully as it will update the version to be release number (without develop)
   - merge the release branch to `main` branch and publish [the previously prepared](#release-preparation) release draft.
   - Wait for the [Github Actions `Release`](https://github.com/utPLSQL/utPLSQL/actions/workflows/release.yml) process to complete successfully. The process will upload release artifacts (`zip` and `tar.gz` files along with `md5`) 
   - After Release build was completed successfully, merge the `main` branch back into `develop` branch. At this point, main branch and release tag should be at the same commit version and artifacts should be uploaded into Github release. 
   - After develop branch was built, increase the version number in `VERSION` file to represent next planned release version.
   - Clone `utplsql.githug.io` project and add a new announcement about next version being released in `_posts`. Use previous announcements as a template. Make sure to set date, time and post title properly.

The following will happen:
   - build executed on branch `release/vX.Y.Z-[something]` updates files `sonar-project.properties`, `VERSION` with project version derived from the release branch name
   - changes to those two files are committed and pushed back to release branch
   - when a Github release is published, a new tag is added in on the repository and a release build is executed
   - With Release build, the documentation for new release is published on `utplsql.github.io` and installation archives are added to the release.

# Note:
The utPLSQL installation files are uploaded by the release build process as release artifacts (separate `zip` and `tar.gz` files).
The release artifacts include HTML documentation generated from MD files, sources and tests
