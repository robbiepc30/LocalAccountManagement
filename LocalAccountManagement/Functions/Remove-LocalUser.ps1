<#
.Synopsis
   Removes local users from computer(s) 
.DESCRIPTION
   Removes local users from computer(s) 
.EXAMPLE
   'User1', 'User2' | Remove-LocalUser -Force  
   Removes User1 and User2 from local computer
.EXAMPLE
   Remove-LocalUser -Name 'User1', 'User2' -ComputerName 'Client01', Client02' -Force  
   Removes User1 and User2 from computer Client01 and Client02
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
            If ($psCmdlet.shouldProcess("$C", "Remove-LocalUser: Account(s): $Name"))
            {
                $objOu = [ADSI]"WinNT://$C"
                foreach ($N in $Name) { 
                    Write-Verbose "Removing user `"$N`" from computer `"$C`""
                    $objOU.Delete("user", $N) 
                }
            }
        }
    }
}