<#
.Synopsis
   Retrieves local users from computer(s) 
.DESCRIPTION
   Retrieves local users from computer(s) 
.EXAMPLE
   'Computer1', 'Computer2' | Get-LocalUser  
   By accepting pipeline input it gets local users from :"computer1" and "compter2"
.EXAMPLE
   Get-LocalUser -ComputerName Computer1
   Gets local users from Computer1
.EXAMPLE
   Get-LocalUser -ComputerName Computer1 -Full
   Gets and returns the full [System.DirectoryServices.DirectoryEntry] object with lots of detail
#>
function Get-LocalUser{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name,
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName=$env:COMPUTERNAME 
    )
    Process 
    { 
        foreach ($C in $ComputerName) 
        { # Do this for each computer in the $ComputerName collection
            Write-Verbose "Retrieving users on `"$C`"" 
            
            $objOu = [ADSI]"WinNT://$C"
            $localUsers = $objOu.psbase.Children | Where-Object { $_.psbase.SchemaClassName -match 'user' }

            foreach ($n in $Name) 
            {
                $users = $localUsers | Where-Object { $_.name -like $n }
                
                # if a wildcard is used there may be more than one result, need to go through each one
                foreach ($u in $users) 
                {
                    $Obj = New-Object -TypeName PSObject -Property @{'Name' = $u.name.ToString();
                                                                    'Description' = $u.description.ToString()}
                    Write-Output $Obj
                }
            }                  
        }
    }
}