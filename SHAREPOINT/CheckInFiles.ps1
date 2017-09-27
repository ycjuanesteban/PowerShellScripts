Add-PSSnapin Microsoft.SharePoint.PowerShell

#Variables for Site URL and Library Name
$WebURL=""
$LibraryName="Documentos"

#Get Site and Library
$Web = Get-SPWeb $WebURL
$DocLib = $Web.Lists.TryGetList($LibraryName)

#Get all Checked out files
$CheckedOutFiles = $DocLib.Items | Where-Object { $_.File.CheckOutStatus -ne "None"} 

#Check in All Checked out Files in the library
ForEach($item in $CheckedOutFiles)
{ 
    $DocLib.GetItemById($item.Id).file.CheckIn("Checked in by Admin") 
    Write-Host "File:'$($item.Name)' has been checked in!"         
}