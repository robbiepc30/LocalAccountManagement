Deploy "Deploy LocalAccountManagement To Dev Folder" {
    By FileSystem {
        FromSource LocalAccountManagement
        To C:\PSDev\LocalAccountManagement
        WithOptions @{
            Mirror = $True
        }
        Tagged Dev
    }
}

Deploy "Deploy LocalAccountManagement To Local Module Folder" {
    By FileSystem {
        FromSource LocalAccountManagement
        To "C:\Program Files\WindowsPowerShell\Modules\LocalAccountManagement"
        WithOptions @{
            Mirror = $True
        }
        Tagged Prod
    }
}

Deploy "Deploy LocalAccountManagement To Production Folder" {
    By FileSystem {
        FromSource LocalAccountManagement
        To "\\robocop\ScriptRepo\LocalAccountManagement"
        WithOptions @{
            Mirror = $True
        }
        Tagged Prod
    }
}