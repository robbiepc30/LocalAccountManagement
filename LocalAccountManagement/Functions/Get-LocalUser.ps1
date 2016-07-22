<#
.Synopsis
   Retrieves local users from computer(s) 
.DESCRIPTION
   Retrieves local users from computer(s) 
.EXAMPLE
   Get-LocalUser
   Gets all user accounts from local computer
.EXAMPLE
   Get-LocalUser test, guest
   Gets user accounts "test" and "guest" on the local computer if they exist
.EXAMPLE
   Get-LocalUser test, guest -ComputerName Computer1, Computer2
   Gets user accounts "test" and "guest" from Computer1 and Computer2 if they exist
.EXAMPLE
   Get-LocalUser *admin* -ComputerName Computer1, Computer2
   Gets all users from Computer1 and Computer2 that has the name "admin" anywhere in the user name 
.EXAMPLE
   'test', 'guest' | Get-LocalUser  
   Gets user accounts "test" and "guest" on the local computer if they exist
.EXAMPLE
    '*admin*' | Get-LocalUser  
    Gets all users accounts ac from local computer that has the name "admin" anywhere in the user name
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
        # KEEP THIS IN THE BEGIN BLOCK!!!PREVENTS DUPLICATE ACCOUNTS FROM DISPLAYING WHEN USING THE PIPELINE AND USING WILDCARDS
        # pulls local accounts form all computers and stores them in array this is done
        # in the Begin part so it prevents problems that can occure if a user uses wildcards that can cause duplicate accounts to show
        # EX: The following accounts exist "Test1", "Test2", "TestGuest"
        # "t*", "*guest*" | Get-LocalUser    ...  If this wasnt in the begin bock but was in the process block the it would display accounts twice
        $computerAccounts = New-Object System.Collections.ArrayList
        foreach ($C in $ComputerName) 
        { # Do this for each computer in the $ComputerName collection          
            [System.Collections.ArrayList]$localUsers = getAllUsers -ComputerName $C
            [void]$computerAccounts.Add(@{'ComputerName' = $C
                                          'UserAccounts' = $localUsers})
        }
    }
    Process 
    { 
        foreach ($ca in $computerAccounts) 
        {
            foreach ($n in $Name) 
            {
                $users = $ca.UserAccounts | Where-Object { $_.name -like $n }
                
                # if a wildcard is used there may be more than one result, need to go through each one
                foreach ($u in $users) 
                {
                    $Obj = New-Object -TypeName PSObject -Property @{'Name'                       = $u.name.ToString()
                                                                     'Description'                = $u.description.ToString()
                                                                     'FullName'                   = $u.FullName
                                                                     'UserFlags'                  = $u.UserFlags
                                                                     'MaxStorage'                 = $u.MaxStorage
                                                                     'PasswordAge'                = $u.PasswordAge
                                                                     'PasswordExpired'            = $u.PasswordExpired
                                                                     'LoginHours'                 = $u.LoginHours
                                                                     'HomeDirectory'              = $u.HomeDirectory
                                                                     'LoginScript'                = $u.LoginScript
                                                                     'Profile'                    = $u.Profile
                                                                     'HomeDirDrive'               = $u.HomeDirDrive
                                                                     'PrimaryGroupID'             = $u.PrimaryGroupID
                                                                     'BadPasswordAttempts'        = $u.BadPasswordAttempts
                                                                     'MinPasswordLength'          = $u.MinPasswordLength
                                                                     'MaxPasswordAge'             = $u.MaxPasswordAge
                                                                     'MinPasswordAge'             = $u.MinPasswordAge
                                                                     'PasswordHistoryLength'      = $u.PasswordHistoryLength
                                                                     'AutoUnlockInterval'         = $u.AutoUnlockInterval
                                                                     'LockoutObservationInterval' = $u.LockoutObservationInterval
                                                                     'MaxBadPasswordsAllowed'     = $u.MaxBadPasswordsAllowed
                                                                     'Guid'                       = $u.Guid
                                                                     'objectSid'                  = $u.objectSid
                                                                     'ComputerName'               = $ca.ComputerName }
                    $Obj.PSObject.TypeNames.Insert(0,"RPC.LocalUser")   
                    # DO NOT REMOVE THIS!!! PREVENTS DUPLICATE ACCOUNTS FROM DISPLAYING WHEN USING -NAME PARAMATER AND USING WILDCARDS
                    # remove record from array list 
                    # If comptuer has multipe accounts that start with a "t", one called "testguest" and a user wanted to find all accounts that start with "t" and all
                    # that have the name "guest" and used the following: Get-LocalUser -Name t*, *guest* this would produce duplicate accounts.
                    # By removing the item from the array list this removes that possibility
                    $ca.UserAccounts.Remove($u) 
                    
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