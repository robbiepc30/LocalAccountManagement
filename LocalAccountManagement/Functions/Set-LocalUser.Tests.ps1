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

Describe "Set-LocalUser" {
    
    $computer1 = "testclient01"
    $computer2 = "testclient02"
    $user1 = "test1"
    $user2 = "test2"
    $password = "SomeSecretPassword"

    $userComputerObject = userComputerObject -Name $user1, $user2 `
                                             -ComputerName $computer1, $computer2

    Mock getUser {} -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
    Mock getUser {} -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) }
    Mock getUser {} -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
    Mock getUser {} -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }
    Mock setPassword {}
    Mock setUser {}

    Context "Test by passing (username, Computername) object via Pipeline" {

       $userComputerObject | Set-LocalUser -Password "lsdkfjsdkljf" -Force
        It "Modifies each user on each computer passed via the pipeline" {
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) } 
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }    
        }
    }

    Context "Test by passing string for username via Pipeline" {
        
        $user1, $user2 | Set-LocalUser -ComputerName $computer1, $computer2 -Password $password -Force
        It "Modifies each user passed in via Pipeline" {
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) } 
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }
        }
    }

    Context "Test by Parameters" {
        
        Set-LocalUser -Name $user1, $user2 -ComputerName $computer1, $computer2 -Password $password -Force
        It "Modifies each user on each computer passed via parameters" {
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer1) }
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer1) } 
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user1) -and ($ComputerName -eq $computer2) }
            Assert-MockCalled getUser -Exactly 1 -ParameterFilter { ($Name -eq $user2) -and ($ComputerName -eq $computer2) }
        }
    }
}
