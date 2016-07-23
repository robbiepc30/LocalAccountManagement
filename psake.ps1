properties {
    $Path = "$PSScriptRoot\LocalAccountManagement"
}

Task Analyze {
    #Invoke-ScriptAnalyzer -Path .\LocalAccountManagement -Recurse | Where -Property FileName  -NotLike "*.Tests.*"
    $saResult = Invoke-ScriptAnalyzer -Path $Path `
                                        -Severity Error, Warning `
                                        -Recurse
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

Task Default -depends Analyze

# ToDo: Add -depends Test when Test Task is added
Task Deploy -depends Analyze, Test {
    Invoke-PSDeploy -Path $PSScriptRoot -Force -Verbose:$VerbosePreference
}


