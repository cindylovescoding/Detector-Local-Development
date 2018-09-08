Set-ExecutionPolicy -ExecutionPolicy Bypass
$logFile = ".\StartUp.log"
"Start preparing VS code" | Out-File -FilePath $logFile -Append -Encoding ascii


$ErrorActionPreference="SilentlyContinue"
$VerbosePreference = "Continue"

Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $logFile

Write-Verbose -Verbose $logFile


# Install latest appservice.diagnostics.compilerhost nuget
$compilerHostNuget = "appservice.diagnostics.compilerhost"
$runtimeHostNuget = "AppServices.Diagnostics.Runtime"
#$nugetDest = "$($PSScriptRoot)\Framework\References"

$nugetDest = "F:\DevDesign-Local\LocalDevFolderSchema\Framework\References"
Write-Verbose -verbose ("Installing Nuget : " + $nuget + "into path " + $nugetDest)


.\nuget.exe install -o $nugetDest $compilerHostNuget

#  nuget install -o $nugetDest $compilerHostNuget
#Install-Package -Destination $nugetDest -Name $runtimeHostNuget 

# Keep latest 2 version of comilerhost nuget

#  Update the _frameworkRef.csx with latest installed package ( Should be PROD installed version)


# Always keep the latest 2 versions of packages
$packagesToRemove = (Get-ChildItem -Directory F:\DevDesign-Local\LocalDevFolderSchema\Framework\References | ? {$_.Name -match $compilerHostNuget}).count -2


if ($packagesToRemove -gt 0)
{
    Get-ChildItem -Directory F:\DevDesign-Local\LocalDevFolderSchema\Framework\References | ? {$_.Name -match $compilerHostNuget} `
    | Sort-Object {[Version] $(if ($_.Name -match "(\d+.){2}\d+") {$Matches[0]} else {  "0.0.0" })} -Descending `
    | Select-Object -Last $packagesToRemove | remove-item -Force -Recurse

    Write-Verbose "Removed $packagesToRemove packages"
}

 $latestPackage = Get-ChildItem -Directory F:\DevDesign-Local\LocalDevFolderSchema\Framework\References | ? {$_.Name -match $compilerHostNuget} `
| Sort-Object {[Version] $(if ($_.Name -match "(\d+.){2}\d+") {$Matches[0]} else {  "0.0.0" })} -Descending `
| Select-Object -First 1 -ExpandProperty Name


# Replace the reference file with the latest version
$referencePath = "$($PSScriptRoot)\..\Framework\_frameworkRef.csx"
(Get-Content $referencePath) -creplace "appservice.diagnostics.compilerhost.*\\", "$($latestPackage)\" | Set-Content $referencePath


# Add the reference region for detector csx
$detectorCsxPath = "$($PSScriptRoot)\Detector\detector.csx"
#$detectorCsxPath = "F:\DevDesign-Local\LocalDevFolderSchema"

$referenceRegionString = @"
#region Framework References and Imports (Do not add or remove anything here)
#load "../Framework/_frameworkRef.csx"
using System;
using System.Linq;
using System.Data;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Diagnostics.DataProviders;
using Diagnostics.ModelsAndUtils;
using Diagnostics.ModelsAndUtils.Attributes;
using Diagnostics.ModelsAndUtils.Models;
using Diagnostics.ModelsAndUtils.Models.ResponseExtensions;
using Diagnostics.ModelsAndUtils.ScriptUtilities;

#endregion

"@


$detectorContent = Get-Content $detectorCsxPath -Raw

$regionToAdd = ""
 
if (!$detectorContent.Contains("#region Framework References and Imports (Do not add or remove anything here)")) 
{
    $regionToAdd = $referenceRegionString
}

$detectorContent =  $regionToAdd + $detectorContent

$detectorContent | Set-Content $detectorCsxPath


# Open csx in vscode

code "$($PSScriptRoot)\Detector" -n

Stop-Transcript
