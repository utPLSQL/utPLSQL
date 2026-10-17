# Release process 

To create a release, follow the below steps.

## Release preparation
   - Create a **draft** of a Release with a new tag number `vX.Y.X`  sourced from the `develop` branch on [github releases page](https://github.com/utPLSQL/utPLSQL/releases) 
   - Populate release description using the `Generate release notes` button
   - Review the auto-generated release notes and update tem if needed
   - Add this line at the end of the release notes: `This release was made possible by our sponsors: https://www.utplsql.org/sponsors.html` (a link, not a list of names, so it always shows who is current)
   - Optionally, split the default `## What's Changed` list into `## New features`, `## Enhancements`, `## Bug fixes`. See previous release notes for details

## Performing a release
   - Publish [the previously prepared](#release-preparation) release draft.
   - Wait for the [Github Actions `Release`](https://github.com/utPLSQL/utPLSQL/actions/workflows/release.yml) process to complete successfully.  The process will do the following:
     - create a new tag
     - generate html documentation to be included in the release file.
     - publish documentation for the new version into utPLSQL site
     - upload release artifacts (`zip` and `tar.gz` files along with `sha256` files)
     - update the CHANGELOG.md file with the release details
     - publish an announcement about the release in the utPLSQL Organization Discussions
     - publish a release post on utplsql.github.io (new post in `docs/announcements/posts`)
     - both announcements are created by the shared [announce-release action](https://github.com/utPLSQL/.github/tree/main/actions/announce-release), also used by utPLSQL-cli, utPLSQL-maven-plugin and utPLSQL-java-api
  - After the release process is finished, manually increase the version number in the `VERSION` file on `develop` branch to start the next release version.
  - Send an announcement about the release on:Twitter(X), BlueSky, LinkedIn account about the utPLSQL release.

# Note:
The release artifacts include HTML documentation generated from MD files, sources and tests
