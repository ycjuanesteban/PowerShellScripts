Add-PSSnapin Microsoft.Sharepoint.Powershell

function PeticionSitio($url)
{
    Write-Host ("Consultando el sitio " + $url) -ForegroundColor Yellow;
    try
    {
        $request = Invoke-WebRequest -Uri $url -UseBasicParsing -UseDefaultCredentials;
    } catch {

    }
}

Write-Host "Consultando los aplicativos web" -ForegroundColor Green;
$was = Get-SPWebApplication -IncludeCentralAdministration |Sort-Object IsAdministrationWebApplication;
foreach($wa in $was)
{
    $site = Get-SPSite $wa.Url;
    
    if($site.AllWebs -ne $null)
    {
        foreach($web in $site.AllWebs)
        {
           PeticionSitio -url $web.Url; 
        }
    }
    else
    {
        PeticionSitio -url $site.Url;
    }
}

