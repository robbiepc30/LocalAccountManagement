properties {
    $Path = "$PSScriptRoot\LocalAccountManagement"
}

Task Analyze {
    $saResult = Invoke-ScriptAnalyzer -Path $Path -Recurse -Severity Error, Warning -ExcludeRule PSAvoidUsingPlainTextForPassword, PSAvoidUsingUserNameAndPassWordParams, PSAvoidUsingWMICmdlet  | 
                where { $_.ScriptName -NotLike "*.Tests.*" }
    if ($saResult ){
        $saResult
        Write-Error "One or more Script Analyzer errors/Warrnings where found.  Build cannot continue!"
    }
}

Task Test {
    $testResults = Invoke-Pester -Script $PSScriptRoot -PassThru
    if($testResults.FailedCount -ne 0) {
        Write-Error "Failed '$($testResults.FailedCount)' test.  Build cannot continue!"
    }
}

Task Default -depends Analyze, Test

Task Deploy -depends Analyze, Test {
    Invoke-PSDeploy -Path $PSScriptRoot -Tags Prod -Force -Verbose:$VerbosePreference
}


