Function Set-LocalUser {
    [CmdletBinding(SupportsShouldProcess=$true,
                    confirmImpact='High')]
    Param([Parameter(Mandatory=$True,
                     ValueFromPipeline=$True,
                     ValueFromPipelineByPropertyName=$true)]
          [String[]]$Name,
          [Parameter(ValueFromPipelineByPropertyName=$true)]
          [String[]]$ComputerName = $env:ComputerName,
          [String]$Password,
          [String]$Description,
          [Switch]$Enable,
          [Switch]$Disable,
          [Switch]$ExpirePassword, #Switch, if used will make user change password at next logon  
          [Switch]$UnExpirePassword, #Switch, if used will uncheck make user change password at next logon
          [Switch]$Force
    )
    Begin
    {
        if ($Force) { $ConfirmPreference = 'None' }
    }
    Process
    {
        $EnableUser = 512
        $DisableUser = 2

        foreach ($C in $ComputerName) 
        {
            If ($psCmdlet.shouldProcess($C, "Set-LocalUser: Account(s): $Name"))
            {
                foreach ($N in $Name)
                {
                    Write-Verbose "Modifying User Account Settings for `"$N`" on Computer `"$C`""
                    $user = getUser -Name $N -ComputerName $C # refactored for Pester Unit test
                
                    if ($Password)
                    {#If no password was entered it skips this step of changing the password
                     Write-Verbose "Setting password for $N account on $C"
                        setPassword -UserObj $user -Password $Password # Refactored for Pester test                
                    }
                
                    if ($Description) 
                    {# if no description was entered it skips this step
                   	    Write-Verbose "Changing description for $N account on $C"
                   	    $user.description = $Description    
                    }
                
                    if ($Enable) {
                   	    Write-Verbose "Enable $N account on $C"
                   	    $user.userflags = $EnableUser
                    }
                    
                    if ($Disable) {
                        Write-Verbose "Disable $N account on $C"
                        $user.userflags = $DisableUser
                    }
                
                    if ($ExpirePassword)
                    {#Checks to see -ChangePass paramater was used, if not it skips this step     
                        Write-Verbose "Password for $N set to expire on $C, user must change password at next logon"
                        $user.passwordExpired = 1 #Sets user expire at next logon 
                    }
                
                    if ($UnExpirePassword)
                    {#Checks to see if -NotChangePass paramater was used, if not it skips this step
                        Write-Verbose "Password for $N set NOT to expire on $C for next logon"
                        $user.passwordExpired = 0 #Sets users password not to expire at next logon 
                    }
                    
                    #Commits changes to the user account
                    setUser -UserObj $user # refactored for Pester Unit test
                }
            }
        }
    }

}

function getUser ($Name, $ComputerName) {
    $user = [ADSI]"WinNT://$ComputerName/$Name,user"
    $user
}

function setUser ($UserObj) {
    $UserObj.SetInfo()
}

function setPassword ($UserObj, $Password) {
    
}

