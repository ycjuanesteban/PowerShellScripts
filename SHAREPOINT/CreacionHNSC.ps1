Write-Host "Cargando dependencias" -ForegroundColor Yellow
Add-PSSnapin Microsoft.SharePoint.Powershell

#1. Url HNSC
$urlHNSC = "url HNSC";
#2. Usuario administrador de la colección de sitios
$Admin = "DOMINIO\usuario";
#3. Url de la aplicación web donde se alojará la colección de sitios
$urlWebApp = "url web app";
#4. Nombre del sitio
$nombreSitio = "Nombre Sitio";
#5. Código de la plantilla a usar
$codigoPlantilla = "STS#0";
#6. Código del lenguaje
$codigoLenguaje = 3082;
#7. Nombre de la base de datos
$nombreBD = "Nombre base de datos";
#8. Instancia servidor o Alias
$servidorBD = "servidorBD";
#9. Crear una nueva base de datos ($true - $false)
#Nota: Si selecciona $false debe en la variable $nombreBD indicar el nombre de la base de datos del web app y esta debe existir
$nuevaBD = $false;

Write-Host "Obteniendo aplicación web" -ForegroundColor Yellow
$webApp = Get-SPWebApplication $urlWebApp -ErrorAction Stop;

Write-Host "Obteniendo la plantilla" -ForegroundColor Yellow
$plantilla = Get-SPWebTemplate $codigoPlantilla -ErrorAction Stop;

if($nuevaBD -eq $true)
{
    Write-Host "Creando base de datos" -ForegroundColor Yellow;
    New-SPContentDatabase -Name $nombreBD -DatabaseServer $servidorBD  -WebApplication $webApp.Url;
}
else
{
    Write-Host "Obteniendo base de datos" -ForegroundColor Yellow;  
}
$bd = Get-SPContentDatabase $nombreBD;


Write-Host "Creando sitio HNSC" -ForegroundColor Yellow
New-SPSite $urlHNSC -OwnerAlias $Admin -HostHeaderWebApplication $webApp.Url -Name $nombreSitio -Template $plantilla -Language $codigoLenguaje -ContentDatabase $bd;
Write-Host "Cración del sitio finalizada" -ForegroundColor Green