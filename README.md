# Libabigail Action

[Libabigail](https://sourceware.org/libabigail/) is "The ABI Generic Analysis and Instrumentation Library"
and it's a tool to help you make sure that your library does not break ABI, or the application
binary interface. How can you do this?

 - For every pull request, check the abidiff against the latest main branch
 - Also have the option to check the PR against the release
 - Require a version bump if there are ABI breaks
 
 
For the libabigail base we use [ghcr.io/auildsi/libabigail](https://github.com/buildsi/build-abi-containers/pkgs/container/libabigail)
 and you can request a new release of the [Dockerfile](https://github.com/buildsi/build-abi-containers/blob/main/docker/libabigail/Dockerfile)
 if it's available for libabigail.
 
## Usage

We recommend a workflow that triggers on pull request and (in parallel) builds:

 - the pull request commit (default checkout without parameters)
 - the latest release
 - the latest version on your main branch
 
And then you can use the action to save your library or binary from each build, and run [abidiff](https://sourceware.org/libabigail/manual/abidiff.html).
Depending on your use case for the run, you can also set a variable to indicate if
the test should be allowed to fail.

**under development** 
