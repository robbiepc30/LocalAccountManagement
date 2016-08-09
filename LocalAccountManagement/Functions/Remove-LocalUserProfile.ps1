<#
.Synopsis
   Removes local users PROFILE from computer(s) 
.DESCRIPTION
   Removes local users PROFILE from computer(s) 
.EXAMPLE
   'User1', 'User2' | Remove-LocalUser  
   Removes User1 and User2 from local computer
.EXAMPLE
   Remove-LocalUserProfile -Name 'User1', 'User2' -ComputerName 'Client01', Client02' -Force  
   Removes User1 and User2 PROFILE from computer Client01 and Client02

.EXAMPLE
   Get-LocalUser *test* | Remove-LocalUserProfile   
   Removes all users PROFILE from local computer with the name "test" anywhere in the username
.EXAMPLE
   Import-Csv UserAccounts.csv | Remove-LocalUserProfile
   Removes all users PROFILE listed in the CSV on the Computers listed in the CSV file
#>
Function Remove-LocalUserProfile {
    [CmdletBinding(SupportsShouldProcess=$true,
                    confirmImpact='High')]
    Param([Parameter(Mandatory=$True,
              	     ValueFromPipeline=$true,
                     ValueFromPipelineByPropertyName=$true)]
          [String[]]$Name,
          [Parameter(ValueFromPipelineByPropertyName=$true)]
          [String[]]$ComputerName = $env:COMPUTERNAME,   
          [Switch]$Force  
    )
    Begin
    {
        if ($Force) { $ConfirmPreference = 'None' }
    }
    Process
    { 
        foreach ($C in $ComputerName)
        {
            If ($psCmdlet.shouldProcess($C, "Remove-LocalUserProfile: Account(s): $Name"))
            {
                foreach ($N in $Name)
                {   # Delete user profile
                    Write-Verbose "Removing local user profile `"$N`" on `"$C`" "
                    removeUserProfile -Name $N -ComputerName $C # Refactored for Pester Test
                }
            }
        }
    }
}

function removeUserProfile ($Name, $ComputerName) {
    $UserProfile = Get-WmiObject Win32_UserProfile -ComputerName $ComputerName -filter  "LocalPath Like '$env:SystemDrive\\users\\$Name'" 
    # if user proifle exists, call Delete mothod to remove profile
    if ($UserProfile) { $UserProfile.Delete() }     
}