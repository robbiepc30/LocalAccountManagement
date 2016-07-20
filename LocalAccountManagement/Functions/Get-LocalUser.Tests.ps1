$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

# helper function
function createUsers([String[]]$User)
{ 
    $userList = @()

    foreach ($u in $User) {
        $userList += [pscustomobject]@{ name = "$u"; description = "$u Account";}
    }

    $userList
}

Describe "Get-LocalUser" {
    
    Context "Pipeline input" {
        $user1 = "test1"
        $user2 = "test2"
    
        Mock Where-Object { createUsers -User $user1, $user2 } -ParameterFilter { $FilterScript -eq "{ `$_.psbase.SchemaClassName -match 'user' }" }
   
        $result = 't*' | Get-LocalUser
    
        It "sldfjk" {
            Assert-MockCalled Where-Object -Exactly 1 {} -ParameterFilter { $FilterScript -eq "{ `$_.psbase.SchemaClassName -match 'user' }" }
        }
        It "returns correct user accounts" {
            $result[0].name | should be $user1
            $result[1].name | should be $user2
        }
    }
    
    #Context "ComputerName parameter" {
    #    $computer1 = "localhost"
    #    $computer2 = "."
    #
    #    Mock Write-Verbose {} -ParameterFilter { $Message -eq "Retrieving users on `"$computer1`"" }
    #    Mock Write-Verbose {} -ParameterFilter { $Message -eq "Retrieving users on `"$computer2`"" }        
    #
    #    $result = Get-LocalUser -ComputerName $computer1, $computer2
    #    
    #    It "Iterates throgh each computer passed by parameter" {
    #        Assert-MockCalled Write-Verbose -Exactly 1 -ParameterFilter { $Message -eq "Retrieving users on `"$computer1`"" }  
    #        Assert-MockCalled Write-Verbose -Exactly 1 -ParameterFilter { $Message -eq "Retrieving users on `"$computer2`"" }
    #    }
    #}
}