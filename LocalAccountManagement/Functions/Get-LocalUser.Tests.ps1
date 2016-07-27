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
    
    Context "Test via pipeline" { 
        $result = '*t*', '*est*' | Get-LocalUser
    
        It "Returns correct user accounts" {
            $users = $result | select -ExpandProperty name
            $users.Contains($user1) | should be $true
            $users.Contains($user2) | should be $true
            $users.Contains($user3) | should be $true
        }

        It "Does not return duplicate accounts when wildcards are used" {
            $result.Count | should be 3
        }
    }

    Context "Test via Parameters" {
        $computer1 = "client01"
        $computer2 = "client02"
        $computer3 = "client03"

        $result = Get-LocalUser "*t*", "*est*" -ComputerName $computer1, $computer2, $computer3

        It "Returns users from each computer" {
            ($result | select -property ComputerName -unique).count | Should be 3 #Check that accounts were returned from 3 computers
        }

        It "Returns all users from each computer" {           
            #Computer1
            ($result | where {($_.Name -eq $user1) -and ($_.ComputerName -eq $computer1)}) -ne $null | should be $true
            ($result | where {($_.Name -eq $user2) -and ($_.ComputerName -eq $computer1)}) -ne $null | should be $true
            ($result | where {($_.Name -eq $user3) -and ($_.ComputerName -eq $computer1)}) -ne $null | should be $true
            
            #Computer2
            ($result | where {($_.Name -eq $user1) -and ($_.ComputerName -eq $computer2)}) -ne $null | should be $true
            ($result | where {($_.Name -eq $user2) -and ($_.ComputerName -eq $computer2)}) -ne $null | should be $true
            ($result | where {($_.Name -eq $user3) -and ($_.ComputerName -eq $computer2)}) -ne $null | should be $true
            
            #Computer3
            ($result | where {($_.Name -eq $user1) -and ($_.ComputerName -eq $computer3)}) -ne $null | should be $true
            ($result | where {($_.Name -eq $user2) -and ($_.ComputerName -eq $computer3)}) -ne $null | should be $true
            ($result | where {($_.Name -eq $user3) -and ($_.ComputerName -eq $computer3)}) -ne $null | should be $true
        }

        It "Does not return duplicate accounts when wildcards are used" {
            $result.Count | should be 9
        }
    }
}