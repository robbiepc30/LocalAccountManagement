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
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name = '*',
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName=$env:COMPUTERNAME 
    )
    Begin 
    {
        
    }
    Process 
    { 
        foreach ($C in $ComputerName) 
        { # Do this for each computer in the $ComputerName collection
            Write-Verbose "Retrieving users on `"$C`"" 
            
            # needed to be able to remove item from array
            [System.Collections.ArrayList]$localUsers = getAllUsers -ComputerName $C

            foreach ($n in $Name) 
            {
                $users = $localUsers | Where-Object { $_.name -like $n }
                
                # if a wildcard is used there may be more than one result, need to go through each one
                foreach ($u in $users) 
                {
                    $Obj = New-Object -TypeName PSObject -Property @{'Name' = $u.name.ToString()
                                                                    'Description' = $u.description.ToString()}                    
                    # remove record from array list, DO NOT REMOVE THIS
                    # If comptuer has multipe accounts that start with a "t", one called "testguest" and and a acount called something "guest"
                    # and uses wildcards to select user accounts such as: Get-LocalUser -Name t*, *guest* this would produce duplicate accounts.  By removing the item
                    # from the array list this removes that possibility
                    $localUsers.Remove($u) 
                    
                    $Obj
                }
            }                  
        }
    }
}

function getAllUsers ($ComputerName) {
    $objOu = [ADSI]"WinNT://$ComputerName"
    $allUsers = $objOu.psbase.Children | Where-Object { $_.psbase.SchemaClassName -match 'user' }

    $allUsers
}