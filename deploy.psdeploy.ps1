Deploy "Deploy AccountCreation To Dev Folder" {
    By FileSystem {
        FromSource AccountCreation
        To C:\PSDev\AccountCreation
        WithOptions @{
            Mirror = $True
        }
        Tagged Dev
    }
}

Deploy "Deploy AccountCreation To Production Folder" {
    By FileSystem {
        FromSource AccountCreation
        To "\\robocop\ScriptRepo\AccountCreation"
        WithOptions @{
            Mirror = $True
        }
        Tagged Prod
    }
}