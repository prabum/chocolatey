$here   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src    = Join-Path (Split-Path $here) 'src'
$script = Join-Path $src 'chocolatey.ps1'

. $script

function Chocolatey-NuGet {
    param(
        $packageName='',
        $source='https://go.microsoft.com/fwlink/?LinkID=206669',
        $version=''
    )

    $script:packageName = $packageName
    $script:version = $version
}

Describe "When installing packages from a manifest that doesn't exist" {

    try {
        Chocolatey-PackagesConfig "TestDrive:\packages.config"
    } catch {
        $script:exception = $_.Exception
    }

    It "should throw an exception" {
        $script:exception.Message.should.match('File not found')
    }

}

Describe "When installing packages from a badly formatted manifest" {

    Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
    <package id="chocolateytestpackage" version="0.1" />
</packages>    
"@

    Chocolatey-PackagesConfig "TestDrive:\packages.config"

    It "should I dunno like do something" {
        # depends on the malformation, really
        #    1. element (like `<pakage ... />`)
        #       The xml object for loop will skip it.
        #    2. attribute (like `<package ... verion="0.1" />`)
        #       A null/empty value will be passed on.
    }

}

Describe "When installing packages from a manifest" {

    Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
    <package id="chocolateytestpackage" version="0.1" />
</packages>    
"@
  
    Chocolatey-PackagesConfig "TestDrive:\packages.config"
    
    It "should call chocolatey nuget with each package and version" {
        $script:packageName.should.be('chocolateytestpackage')
        $script:version.should.be('0.1')
    }

}

Describe "When installing packages from a manifest with no versions" {

    Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
    <package id="chocolateytestpackage" />
</packages>    
"@
  
    Chocolatey-PackagesConfig "TestDrive:\packages.config"
    
    It "should call chocolatey nuget without a version specified" {
        $script:packageName.should.be('chocolateytestpackage')
        $true.should.be(($script:version -eq $null))
    }

}