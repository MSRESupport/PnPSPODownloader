Import-Module PnP.Powershell

$ctx = Connect-PnPOnline -Url "siteurl" -interactive -ClientID clientID

function Get-FolderList {
    param (
        $folderPath
    )
    return Get-ChildItem $folderPath -Directory | Select Name
}

function Get-FileList {
    param (
        $folderPath
    )
    return Get-ChildItem $folderPath -File | Select Name
}

function Add-FilesFromFileList {
    param (
        $folderPath,
        $fileList,
        $uploadPath
    )

    foreach ($file in $fileList) {
        Add-PnPFile -Path "$($folderPath)\$($file.Name)" -Folder $uploadPath
    }
}

function Start-PnPUpload {
    param (
        $folderPath,
        $uploadPath
    )

    Write-Host "Uploading content of $($folderPath) to $($uploadPath)"

    $fileList = Get-FileList $folderPath
    Add-FilesFromFileList $folderPath $fileList $uploadPath

    $folderList = Get-FolderList $folderPath
    foreach ($folder in $folderList) {
        Add-PnPFolder -Name $folder.Name -Folder $uploadPath
        Start-PnPUpload "$folderPath\$($folder.Name)" "
        $uploadPath\$($folder.Name)"
    }
}

$startingFolder = "C:\Shared Documents"
$uploadPath = "\AccountingData"

Start-PnPUpload $startingFolder $uploadPath
