$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "t" {
    
    #$insideScriptBlock = '"A"'
    #$scriptBlock = [scriptblock]::Create($insideScriptBlock)

    Mock Where-Object {"bb"} -ParameterFilter {$FilterScript -eq $($scriptBlock)} 
    Mock Write-Output {"bb"} -ParameterFilter {$InputObject -eq '{"a"}'} 

    t
    
    It "ran where-object mock" {
        Assert-MockCalled Where-Object -Scope Describe -ParameterFilter {[String]$FilterScript -eq '"A"'}   
    }
    
    It "ran write-output mock" {
        Assert-MockCalled Write-Output -Scope Describe -ParameterFilter {$InputObject -eq '{"a"}'} 
    }
    It "does something useful" {
        t | should be "bb"
    }
}
