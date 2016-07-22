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
    
    $user1 = "test1"
    $user2 = "test2"
    $user3 = "test3"

    Mock getAllUsers { createUsers -User $user1, $user2, $user3 }
    
    Context "Via Pipeline" { 
        $result = '*t*' | Get-LocalUser
    
        It "sldfjk" {
            Assert-MockCalled getAllUsers -Exactly 1
        }
        It "returns correct user accounts" {
            $users = $result | select -ExpandProperty name
            $users.Contains($user1) | should be $true
            $users.Contains($user2) | should be $true
            $users.Contains($user3) | should be $true
        }

        It "Does not return duplicate accounts when wildcards are used" {
            $result.Count | should be 3
        }
    }

    Context "Via Paramaters" {
        $result = Get-LocalUser "*t*", "*est*" 

        It "Does not return duplicate accounts when wildcards are used" {
            $result.Count | should be 5
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