# Libabigail Action

[Libabigail](https://sourceware.org/libabigail/) is "The ABI Generic Analysis and Instrumentation Library"
and it's a tool to help you make sure that your library does not break ABI, or the application
binary interface. How can you do this?

 - For every pull request, check the abidiff against the latest main branch
 - Also have the option to check the PR against the release
 - Require a version bump if there are ABI breaks
  
For the libabigail base we use [ghcr.io/buildsi/libabigail](https://github.com/buildsi/build-abi-containers/pkgs/container/libabigail)
 and you can request a new release of the [Dockerfile](https://github.com/buildsi/build-abi-containers/blob/main/docker/libabigail/Dockerfile)
 if it's available for libabigail.
 
## Usage

We recommend a workflow that triggers on pull request and (in parallel) builds:

 - the pull request commit (default checkout without parameters)
 - the latest release
 - the latest version on your main branch
 
And then you can use the action to save your library or binary from each build, and run [abidiff](https://sourceware.org/libabigail/manual/abidiff.html).
Depending on your use case for the run, you can also set a variable to indicate if
the test should be allowed to fail. Here is an example.

### Example 

Let's say we have the repository [buildsi/build-abi-test-mathclient](https://github.com/buildsi/build-abi-test-mathclient).
We have two releases, 1.0 andn 2.0 (on the main branch) and version 2.0 has an ABI break. For the purposes
of the example, let's pretend version 2.0 isn't released and we are opening a PR against the current main (still with version 1.0)
and we want to ensure that no ABI is broken. We would want to:

 - Do a build of the main branch
 - Do a build of our pull request
 - Do a build of the last release (1.0)

And for all of these cases, we'd want to run `abidiff` to ensure there are no breaks! Note that since
we are going to be saving our binaries (or libraries in this case) as artifacts and then loading them
in the same job, we are artificially renaming them. If you've set the `SONAME` this shouldn't be an issue.
Our workflow might look like the following:

```yaml
name: Run Libabigail
on: [pull_request]

jobs:
  build-release:
    runs-on: ubuntu-latest
    steps:
    - name: Build Previous Release
      uses: actions/checkout@v3
      with:
        ref: 1.0.0
    - name: Build Release Binary and Rename
      run: make && cp libmath.so libmath.1.so
    - name: Upload results
      uses: actions/upload-artifact@v2-preview
      with:
        name: libmath.1.so
        path: libmath.1.so

  build-pull-request:
    runs-on: ubuntu-latest
    steps:
    - name: Build Pull Request
      uses: actions/checkout@v3
    - name: Build Binary and Rename
      run: make && cp libmath.so libmath.dev.so
    - name: Upload results
      uses: actions/upload-artifact@v2-preview
      with:
        name: libmath.dev.so
        path: libmath.dev.so

  build-main:
    runs-on: ubuntu-latest
    steps:
    - name: Build Main
      uses: actions/checkout@v3
      with:
        ref: main
    - name: Build Binary
      run: make && cp libmath.main.so libmath.main.so
    - name: Upload results
      uses: actions/upload-artifact@v2-preview
      with:
        name: libmath.main.so
        path: libmath.main.so

  libabigail:
    runs-on: ubuntu-latest
    needs: [build-release, build-main, build-pull-request]
    steps:
    - name: Download Previous Release
      uses: actions/download-artifact@v2
      with:
        name: libmath.1.so

    - name: Download Latest Main (or PR)
      uses: actions/download-artifact@v2
      with:
        name: libmath.main.so

    - name: Download Pull Request Build
      uses: actions/download-artifact@v2
      with:
        name: libmath.dev.so

    - name: Show Files
      run: ls

    - name: Checkout Libabigail Action
      uses: actions/checkout@v3

    # You can add allow_fail: true if you expect a failure
    - name: Compare Main to Pull Request
      uses: buildsi/libabigail-action@main
      with: 
        abidiff: libmath.main.so libmath.dev.so
        abidw: "--abidiff libmath.dev.so"

    # You can add allow_fail: true if you expect a failure
    - name: Compare Release to Pull Request
      uses: buildsi/libabigail-action@main
      id: release-to-pr
      with: 
        abidiff: libmath.1.so libmath.dev.so

    - name: Example to show output
      env:
        retval: ${{ steps.release-to-pr.outputs.retval }}
      run: echo "The return code was ${retval}, do something custom here"
```

There are other checks you can do that we might recommend, such as looking at the return
code of the run, and allowing it to fail only if the soname is changed. We set an output
to help with that! If you'd like further help setting this up or example please
[let us know](https://github.com/buildsi/libabigail-action/issues). There are
additional examples in [examples](examples) (including the one above!)
