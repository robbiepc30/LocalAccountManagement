<#
.Synopsis
   Removes local users from computer(s) 
.DESCRIPTION
   Removes local users from computer(s) 
.EXAMPLE
   'User1', 'User2' | Remove-LocalUser  
   Removes User1 and User2 from local computer
.EXAMPLE
   Remove-LocalUser -Name 'User1', 'User2' -ComputerName 'Client01', Client02' -Force  
   Removes User1 and User2 from computer Client01 and Client02

.EXAMPLE
   Get-LocalUser *test* | Remove-LocalUser   
   Removes all users from local computer with the name "test" anywhere in the username
.EXAMPLE
   Import-Csv UserAccounts.csv | Remove-LocalUser   
   Removes all users listed in the CSV on the Computers listed in the CSV file
#>
function Remove-LocalUser {
    [CmdletBinding(SupportsShouldProcess=$true,
                    confirmImpact='High')]
    Param(
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName = $env:COMPUTERNAME,   
        [Switch]$Force  
    )
    Begin
    {
        if ($Force) {$ConfirmPreference = 'None'}
    }
    Process
    {
        foreach ($C in $ComputerName) #Do this for each computer in the $ComputerName collection
        {
            If ($psCmdlet.shouldProcess($C, "Remove-LocalUser: Account(s): $Name"))
            {
                $objOu = getADSIObject -ComputerName $C
                foreach ($N in $Name) 
                { 
                    Write-Verbose "Removing user `"$N`" from computer `"$C`""
                    removeLocalUser -ADSIObject $objOu -Name $N
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
function removeLocalUser ($ADSIObject, $Name ) { 
    $ADSIObject.Delete("user", $Name) 
}