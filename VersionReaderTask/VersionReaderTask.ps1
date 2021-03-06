﻿Param (
    [string]$searchPattern = "**\*.??proj",
    [string]$variablesPrefix = "",
    [string]$buildPrefix = "."
)

# Write all params to the console.
Write-Host "VersionReader v1.15"
Write-Host "==================="
Write-Host ("Search Pattern: " + $searchPattern)
Write-Host ("Variables Prefix: " + $variablesPrefix)
Write-Host ("Build Prefix: " + $buildPrefix)

function SetBuildVariable([string]$varName, [string]$varValue) {
    $varName = $variablesPrefix + $varName
    $versionBuild = $varValue + $buildPrefix + $Env:BUILD_BUILDID
    Write-Host ("Setting variable " + $varName + " = '" + $varValue + "'")
    Write-Host ("Setting variable " + $varName + "_build = '" + $versionBuild + "'")
    Write-Output ("##vso[task.setvariable variable=" + $varName + ";]" + $varValue )
    Write-Output ("##vso[task.setvariable variable=" + $varName + "_Build;]" + $versionBuild )
}

function SetVersionVariables([xml]$xml) {
    [string]$version = ([string]$xml.Project.PropertyGroup.Version).Trim()
    if ($version -ne "") {
        Write-Host ("Version property value found with version " + $version)
        SetBuildVariable "Version" $version
        return
    }

    [string]$assemblyVersion = ([string]$xml.Project.PropertyGroup.AssemblyVersion).Trim()
    if ($assemblyVersion -ne "") {
        Write-Host ("AssemblyVersion property value found with version " + $assemblyVersion)
        SetBuildVariable "Version" $assemblyVersion
        return
    }

    Write-Host ("No Version or AssemblyVersion property value found");

    # check for VersionSuffix
    [string]$versionSuffix = ([string]$xml.Project.PropertyGroup.VersionSuffix).Trim()
    if ($versionSuffix -eq "") {
        Write-Host ("No VersionSuffix property value found");
    }
    else {
        SetBuildVariable "VersionSuffix" $versionSuffix
    }

    # check for VersionPrefix
    [string]$versionPrefix = ([string]$xml.Project.PropertyGroup.VersionPrefix).Trim()
    if ($versionPrefix -eq "") {
        # When a new 2017-format project is created there are no version tags set
        # but when you view Project properties it defaults to 1.0.0. We will assume this is 
        # the case here and select 1.0.0
        Write-Host ("No VersionPrefix property value found, using VersionPrefix 1.0.0 as the default");
        SetBuildVariable "VersionPrefix" "1.0.0"
    }
    else {
        SetBuildVariable "VersionPrefix" $versionPrefix
    }    
}

$filesFound = Get-ChildItem -Path $searchPattern -Recurse

if ($filesFound.Count -eq 0) {
    Write-Warning ("No files matching pattern found.")
}

if ($filesFound.Count -gt 1) {
    Write-Warning ("Multiple assemblyinfo files found.")
}

foreach ($fileFound in $filesFound) {
    Write-Host ("Reading file: " + $fileFound)
    [xml]$XmlDocument = Get-Content -Path $fileFound
    SetVersionVariables($XmlDocument)
}
