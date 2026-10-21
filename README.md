# repo
TTLongDL's personal jailbreak tweak repository


## Facebook Plus release publishing

The [Facebook Plus APT publishing workflow](.github/workflows/publish-fbplus-roothide.yml) is manual. It discovers the latest published stable release from [ttlongdl/Facebook-Plus](https://github.com/ttlongdl/Facebook-Plus/releases), downloads its Rootless (`iphoneos-arm64`) and RootHide (`iphoneos-arm64e`) DEBs, verifies package identity/version/architecture and file contents, and regenerates `Packages` and `Packages.gz` before committing changes. Previous versions are retained for rollback.

For a new version: first update `control` in Facebook-Plus, publish the three DEBs, then run the APT workflow. The version is derived from the published tag; do not edit the APT workflow to bump versions.
