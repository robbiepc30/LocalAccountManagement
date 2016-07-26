<#
.Synopsis
   Creates local user(s) on computer(s) 
.DESCRIPTION
   Creates local user(s) on computer(s) 
.EXAMPLE
   New-LocalUser -Name 'User1', 'User2' -Password 'SuperSecretPassword' 
   Creates "User1" and "User2" on local computer 
.EXAMPLE
   New-LocalUser -Name 'User1', 'User2' -ComputerName 'Client01', 'Client02', 'Client03' -Password 'SuperSecretPassword' 
   Creates "User1" and "User2" on computers "Client01", "Client02", and "Client03"
.EXAMPLE
   'User1', 'User2' | New-LocalUser -Password 'SuperSecretPassword' 
   Creates "User1" and "User2" on local computer
.EXAMPLE
   Import-Csv UserAccounts.csv | New-LocalUser -Password 'SuperSecretPassword' -Description 'Guest Accounts'
   Creates the users on all the computers listed in CSV file



#>
Function New-LocalUser {
    [CmdletBinding(SupportsShouldProcess=$true,
                    confirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName=$env:COMPUTERNAME,
        [Parameter(Mandatory=$True)]
        [String]$Password,
        [String]$Description
    )
    Process
    { 
        foreach($C in $ComputerName)
        { 
            If ($psCmdlet.shouldProcess($C, "New-LocalUser: Account(s): $Name"))
            {
                $objOu = getADSIObject -ComputerName $C
                foreach($N in $Name)
                {
                    Write-Verbose "Creating account `"$N`" on `"$C`" "
                    newLocalUser -ADSIObject $objOU -Name $N -Password $Password -Description $Description
                }
            }
        }
    }
}

# refactored this to make it easier to Mock for Pester Unit test
function getADSIObject ($ComputerName) {
    $objOu = [ADSI]"WinNT://$ComputerName"

    $objOu
}

# refactored this to make it easier to Mock for Pester Unit test
function newLocalUser ($ADSIObject, $Name, $Password, $Description) {
    $objUser = $ADSIObject.Create("user", $N)
    $objUser.setpassword($Password)
    $objUser.put("description",$Description)
    $objUser.SetInfo()
}