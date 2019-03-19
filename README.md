# VersionReaderTask
VSTS build task to read Version tag from project files

Reads the `<Version>` tag from new `csproj` and `vbproj` 2017 format files into environment variables.

This tool was created to fix an issue with the new `.xxproj` project format. The new format does not support wildcard in the version and therefore auto-append of build suffix, which was previously supported.

Optionally prefix the variable values so multiple projects can be read.

Adapted from [AssemblyInfoReaderTask](https://github.com/kyleherzog/AssemblyInfoReaderTask) with thanks to [kyleherzog](https://github.com/kyleherzog)

## Example Usage

The `VersionReaderTask` can be added after the build or the test task to extract the version details from the project. In the example below it runs after the test task and extracts the version from the `Ambolt.csproj` file.

![VersionReaderTask](images/task1.png)

The value is then used in a `dotnet pack` task as follows:

![packtask](images/task2.png)
Note the **Automatic package versioning** is set to `Use an environment variable`
and the **Environment variable** is set to `VERSION_BUILD` value generated by the version reader task.

### Version 1.11

Amended code to ensure version has a '.' at the end before the BUILDNO (fixed bug in v1.10)

### Version 1.9

Added `.Trim()` to version reads - can sometimes have space after the version tag.

### Version 1.8

Added fix for blank Version. Sometimes in simple projects the `Version` tag is absent because the value is the same as the `AssemblyVersion`. Added a check for a blank version being returned and attempts to use the `AssemblyVersion` value instead.
