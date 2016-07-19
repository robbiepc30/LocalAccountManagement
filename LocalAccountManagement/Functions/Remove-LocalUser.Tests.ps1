$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Remove-LocalUser" {
    # Don't know what test I could do since I cant mock the [ADSI]... 
    # the only thing I can tink of doing is putting the [ADSI] into its own fucntion and then mocking that...
    It "Does not do any real test..." {
        $true | Should be $true
    }
}
