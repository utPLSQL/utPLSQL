## Release process 

To create a release follow the below steps

## Release preparation
   - Create a **draft** of a Release with a new tag number `vX.Y.X`  sourced from the `develop` branch on [github releases page](https://github.com/utPLSQL/utPLSQL/releases) 
   - Populate release description using the `Generate release notes` button
   - Review the auto-generated release notes and update tem if needed
   - Split the default `## What's Changed` list into `## New features`, `## Enhancements`, `## Bug fixes`. See previous release notes for details

## Performing a release
   - Publish [the previously prepared](#release-preparation) release draft.
   - Wait for the [Github Actions `Release`](https://github.com/utPLSQL/utPLSQL/actions/workflows/release.yml) process to complete successfully. The process will upload release artifacts (`zip` and `tar.gz` files along with `md5`) 
   - After Release build was completed successfully, merge the `develop` branch into `main` branch. At this point, main branch and release tag should be at the same commit version and artifacts should be uploaded into Github release. 
   - Increase the version number in the `VERSION` file on `develop` branch to open start next release version.
   - Clone `utplsql.githug.io` project and:
     - Add a new announcement about next version being released in `docs/_posts`. Use previous announcements as a template. Make sure to set date, time and post title properly. 
     - Add the post to list in `mkdocs.yml` file in root directory of that repository.
     - Add the link to the post at the beginning of the `docs/index.md` file.
     - Send the announcement on Twitter(X) accoiunt abut utPLSQL release.

The following will happen:
   - When a Github release is published, a new tag is added in on the repository and a release build is executed
   - With Release action, the documentation for new release is published on `utplsql.github.io` and installation archives are added to the release.

# Note:
The utPLSQL installation files are uploaded by the release build process as release artifacts (separate `zip` and `tar.gz` files).
The release artifacts include HTML documentation generated from MD files, sources and tests
