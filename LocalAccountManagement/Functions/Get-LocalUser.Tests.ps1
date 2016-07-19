$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

# helper function
function createUsers 
{ 
    @([pscustomobject]@{ name = "User1"; description = "User 1 Account";},
      [pscustomobject]@{ name = "User2"; description = "User 2 Account";})
}

Describe "Get-LocalUser" {
    
    Context "Pipeline input" {
        $computer1 = "localhost"
        $computer2 = "."
    
        Mock Write-Verbose {} -ParameterFilter { $Message -eq "Retrieving users on `"$computer1`"" }
        Mock Write-Verbose {} -ParameterFilter { $Message -eq "Retrieving users on `"$computer2`"" }
        Mock Where-Object { createUsers }
   
        $result = $computer1, $computer2 | Get-LocalUser
    
        It "Iterates throgh each computer passed through the pipeline" {
            Assert-MockCalled Write-Verbose -Exactly 1 -ParameterFilter { $Message -eq "Retrieving users on `"$computer1`"" }
            Assert-MockCalled Write-Verbose -Exactly 1 -ParameterFilter { $Message -eq "Retrieving users on `"$computer2`"" }        
        }
        It "returns user accounts for each computer" {
            $result[0].name | should be "User1"
            $result[1].name | should be "User2"
            $result[2].name | should be "User1"
            $result[3].name | should be "User2"
        }
    }
    
    Context "ComputerName parameter" {
        $computer1 = "localhost"
        $computer2 = "."
    
        Mock Write-Verbose {} -ParameterFilter { $Message -eq "Retrieving users on `"$computer1`"" }
        Mock Write-Verbose {} -ParameterFilter { $Message -eq "Retrieving users on `"$computer2`"" }        

        $result = Get-LocalUser -ComputerName $computer1, $computer2
        
        It "Iterates throgh each computer passed by parameter" {
            Assert-MockCalled Write-Verbose -Exactly 1 -ParameterFilter { $Message -eq "Retrieving users on `"$computer1`"" }  
            Assert-MockCalled Write-Verbose -Exactly 1 -ParameterFilter { $Message -eq "Retrieving users on `"$computer2`"" }
        }
    }
}