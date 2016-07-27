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
        foreach($C in $ComputerName)
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
    $UserProfile.Delete() #Deletes user profile
}