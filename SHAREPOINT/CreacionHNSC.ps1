Write-Host "Cargando dependencias" -ForegroundColor Yellow
Add-PSSnapin Microsoft.SharePoint.Powershell

#1. url HNSC
$urlHNSC = "http://PruebaHNSC";
#2. Usuario administrador de la colección de sitios
$Admin = "INTERGRUPO\adminfcaf2";
#3. Url de la aplicación web donde se alojará la colección de sitios
$urlWebApp = "http://v-jyarce:8005";
#4. Nombre del sitio
$nombreSitio = "Prueba HNSC";
#5. Código de la plantilla a usar
$codigoPlantilla = "STS#0";
#6. Código del lenguaje
$codigoLenguaje = 3082;
#7. Nombre de la base de datos
$nombreBD = "BDBorrar";
#8. Instancia servidor o Alias
$servidorBD = "SP13SQL";

Write-Host "Obteniendo aplicación web" -ForegroundColor Yellow
$webApp = Get-SPWebApplication $urlWebApp -ErrorAction Stop;

Write-Host "Obteniendo la plantilla" -ForegroundColor Yellow
$plantilla = Get-SPWebTemplate $codigoPlantilla -ErrorAction Stop;

Write-Host "Creando base de datos" -ForegroundColor Yellow
New-SPContentDatabase -Name $nombreBD -DatabaseServer $servidorBD  -WebApplication $webApp.Url -ErrorAction Stop;
$bd = Get-SPContentDatabase $nombreBD -ErrorAction Stop;

Write-Host "Creando sitio HNSC" -ForegroundColor Yellow
New-SPSite $urlHNSC -OwnerAlias $Admin -HostHeaderWebApplication $webApp.Url -Name $nombreSitio -Template $plantilla -Language $codigoLenguaje -ContentDatabase $bd;

Write-Host "Cración del sitio de colección finalizada" -ForegroundColor Green