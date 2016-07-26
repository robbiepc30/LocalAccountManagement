$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

# helper function
function userComputerObject ([String[]]$Name, [String[]]$ComputerName) {
    $objArray = @()

    foreach ($c in $ComputerName) {
        foreach ($n in $Name) {
            $objArray += [PSCustomObject]@{Name = $n; ComputerName = $c}
        }
    }

    $objArray
}

Describe "New-LocalUser" {
   
    $computer1 = "testclient01"
    $computer2 = "testclient02"
    $computer3 = "testclient03"
    $user1 = "test1"
    $user2 = "test2"
    $user3 = "test3"
    $password = "SomeSecretPassword"

    $userComputerObject = userComputerObject -Name $user1, $user2, $user3 `
                                             -ComputerName $computer1, $computer2, $computer3 `

    Mock getADSIObject {} -ParameterFilter { $ComputerName -eq $computer1 }
    Mock getADSIObject {} -ParameterFilter { $ComputerName -eq $computer2 }
    Mock getADSIObject {} -ParameterFilter { $ComputerName -eq $computer3 }

    Mock newLocalUser {} -ParameterFilter { $Name -eq $user1 }
    Mock newLocalUser {} -ParameterFilter { $Name -eq $user2 }
    Mock newLocalUser {} -ParameterFilter { $Name -eq $user3 }

    Context "Test by passing object with Username, Computername, and Password via Pipeline" {
        
        $userComputerObject | New-LocalUser -Password $password

        It "Goes through each computer passed via the pipeline" {
            # process block in Remove-LocalUser will run once for each object passed via pipeline, thats why this is 3 times instead of 1 time
            Assert-MockCalled getADSIObject -Exactly 3 -ParameterFilter { $ComputerName -eq $computer1 } 
            Assert-MockCalled getADSIObject -Exactly 3 -ParameterFilter { $ComputerName -eq $computer2 }
            Assert-MockCalled getADSIObject -Exactly 3 -ParameterFilter { $ComputerName -eq $computer3 }
        }

        It "Creates each user on each computer passed in via the pipeline" {
            Assert-MockCalled newLocalUser -Exactly 3 -ParameterFilter { $Name -eq $user1 }
            Assert-MockCalled newLocalUser -Exactly 3 -ParameterFilter { $Name -eq $user2 }
            Assert-MockCalled newLocalUser -Exactly 3 -ParameterFilter { $Name -eq $user3 }
        } 
    }

    Context "Test by passing string via pipeline for usernames" {

        $user1, $user2, $user3 | New-LocalUser -Password $password
        it "Creates each user passed via pipeline by string" {
            Assert-MockCalled newLocalUser -Exactly 1 -ParameterFilter { $Name -eq $user1 }
            Assert-MockCalled newLocalUser -Exactly 1 -ParameterFilter { $Name -eq $user2 }
            Assert-MockCalled newLocalUser -Exactly 1 -ParameterFilter { $Name -eq $user3 }
        }
    }

    Context "Test via Parameters" {
        
        New-LocalUser -Name $user1, $user2, $user3 -ComputerName $computer1, $computer2, $computer3 -Password $password
        It "Goes through each computer passed via the -ComputerName parameter" {
            Assert-MockCalled getADSIObject -Exactly 1 -ParameterFilter { $ComputerName -eq $computer1 }
            Assert-MockCalled getADSIObject -Exactly 1 -ParameterFilter { $ComputerName -eq $computer2 }
            Assert-MockCalled getADSIObject -Exactly 1 -ParameterFilter { $ComputerName -eq $computer3 }
        }

        It "Creates each user from each computer passed in via the -ComputerName and -Name parameters" {
            Assert-MockCalled newLocalUser -Exactly 3 -ParameterFilter { $Name -eq $user1 }
            Assert-MockCalled newLocalUser -Exactly 3 -ParameterFilter { $Name -eq $user2 }
            Assert-MockCalled newLocalUser -Exactly 3 -ParameterFilter { $Name -eq $user3 }
        }
    }
}
