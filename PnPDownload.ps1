Import-Module PnP.Powershell

$ctx = Connect-PnPOnline -Url "siteurl" -interactive -ClientID "clientid"

function Get-FolderList {
    param (
        $folderPath
    )
    return $folderList = Get-PnPFolderInFolder -FolderSiteRelativeUrl $folderPath | Select Name 
}

function Get-FileList {
    param (
        $folderPath
    )
    return $fileList = Get-PnPFileInFolder -FolderSiteRelativeUrl $folderPath | Select Name 
}

function Get-FilesFromFileList {
    param (
        $folderPath,
        $fileList,
        $downloadPath
    )

    foreach ($file in $fileList) {
        Get-PnPFile -Url "$folderPath\$($file.Name)" -AsFile -Filename $file.Name -Path $downloadPath
    }
}

function Start-PnPDownload {
    param (
        $folderPath,
        $downloadPath
    )

    Write-Host "Downloading content of $($folderPath) to $($downloadPath)"

    $fileList = Get-FileList $folderPath
    Get-FilesFromFileList $folderPath $fileList $downloadPath

    $folderList = Get-FolderList $folderPath
    foreach ($folder in $folderList) {
        New-Item -Path $downloadPath -Name $folder.Name -ItemType Directory
        Start-PnPDownload "$folderPath\$($folder.Name)" "$downloadPath\$($folder.Name)"
    }
}

$startingFolder = '\Shared Documents'
$downloadPath = "C:\$($startingFolder)"

Start-PnPDownload $startingFolder $downloadPath
