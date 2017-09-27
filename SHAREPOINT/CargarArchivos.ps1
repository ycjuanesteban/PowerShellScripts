# ---- Script settings ---- 
$sourceDocumentPath = "" # Source document to spawn new documents from for the creation
 
# Settings for the destination to create documents in
$webUrl = ""
$docLibraryName = "Documentos"
$folderPathWithinDocLibrary = ""
 
# -------------------------
 
$web = Get-SPWeb $webUrl
$docLibrary = $web.Lists[$docLibraryName]
$docLibraryUrl = $docLibrary.RootFolder.ServerRelativeUrl
$uploadfolder = $web.getfolder($docLibraryUrl + $folderPathWithinDocLibrary)
 
$documents = Get-ChildItem -Path $sourceDocumentPath;
$countDocuments = $documents.Length;
$step = 100/$countDocuments;
$progress = 0;

foreach($document in $documents)
{
    #Open file
    $file = get-item $document.FullName;
    $fileStream = ([System.IO.FileInfo] (Get-Item $file.FullName)).OpenRead()
 
    # Create documents in SharePoint
    Write-Progress -Activity "Copiado de archivo" -PercentComplete $progress -CurrentOperation ("Copiando " + $document.Name)

    $newFilePath = $docLibraryUrl + $folderPathWithinDocLibrary + "/" + $document.Name;
    $spFile = $uploadfolder.Files.Add($newFilePath, [System.IO.Stream]$fileStream, $true);
    #Close file stream
    $fileStream.Close();
    $progress += $step;
}
 
#Dispose web
$web.Dispose();