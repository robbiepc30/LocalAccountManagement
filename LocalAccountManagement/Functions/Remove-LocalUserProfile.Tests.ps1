$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function userComputerObject ([String[]]$Name, [String[]]$ComputerName) {
    $objArray = @()

    foreach ($c in $ComputerName) {
        foreach ($n in $Name) {
            $objArray += [PSCustomObject]@{Name = $n; ComputerName = $c}
        }
    }

    $objArray
}

Describe "Remove-LocalUserProfile" {

    $computer1 = "testclient01"
    $computer2 = "testclient02"
    $user1 = "test1"
    $user2 = "test2"

    $userComputerObject = userComputerObject -Name $user1, $user2 `
                                             -ComputerName $computer1, $computer2

    Mock removeUserProfile {} -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
    Mock removeUserProfile {} -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) }
    Mock removeUserProfile {} -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
    Mock removeUserProfile {} -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }

    Context "Test by passing (username, Computername) object via Pipeline" {

       $userComputerObject | Remove-LocalUserProfile -Force
        It "Removes each user profile on each computer passed via the pipeline" {
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) } 
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }    
        }
    }

    Context "Test by passing string for username via Pipeline" {
        
        $user1, $user2 | Remove-LocalUserProfile -ComputerName $computer1, $computer2 -Force
        It "Removes each user profile passed in via Pipeline" {
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) } 
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }
        }
    }

    Context "Test by Parameters" {
        
        Remove-LocalUserProfile -Name $user1, $user2 -ComputerName $computer1, $computer2 -Force
        It "Removes each user profile on each computer passed via parameters" {
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) } 
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
            Assert-MockCalled removeUserProfile -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }
        }
    }
}
