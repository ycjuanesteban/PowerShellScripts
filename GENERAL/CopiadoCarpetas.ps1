#MENSAJE A GUARDAR EN EL ARCHIVO commit.txt
param ( [string]$Mensaje_Commit = "")

if(-not($Mensaje_Commit))
{
    $Mensaje_Commit = "Mensaje commit por defecto"
}

#SCRIPT QUE HACE UNA COPIA DEL FORLDER DESIGNADO EN $RutaOrigen
$DEBUG = 0

#VARIABLES REQUERIDAS
$NombreApp = "APP"
$RutaOrigen = 'CARPETA_ORIGEN'
$RutaDestino = "CARPETA_DESTINO"
$RutaDestinoFecha = $($RutaDestino) + (Get-Date -Format u).Split(' ')[0].Replace('-','') 

#VERIFICA SI EXISTE LA CARPETA DEL DÍA ACTUAL, DE NO EXISTIR LA CREA
if(!(Test-Path -Path $RutaDestinoFecha )){
    New-Item -ItemType directory -Path $RutaDestinoFecha
}

$NumCarpetas = (get-childitem -Path $RutaDestinoFecha | where-object { $_.PSIsContainer }).Count
$RutaFinal = $RutaDestinoFecha + '\' + $NombreApp + '_' + $NumCarpetas + '\'

if($DEBUG -eq 1){
    Write-Host "DEBUG" -ForegroundColor Red
    Write-Host "Ruta Origen -> " + $RutaOrigen -ForegroundColor Yellow
    Write-Host "Ruta Destino -> " + $RutaDestinoFecha -ForegroundColor Yellow
    Write-Host "Ruta Final -> " + $RutaFinal -ForegroundColor Yellow
}

#COPIA LAS CARPETAS DEL ORIGEN AL DESTINO
Write-Host "Copiando los archivos" -ForegroundColor Green
Copy-Item  $RutaOrigen  $RutaFinal -Recurse

#CREA EL ARCHIVO commit.txt Y GUARDA EL TEXTO DE LA VARIABLE $Mensaje_Commit
Write-Host "Creando archivo commit" -ForegroundColor Green
New-Item $($RutaFinal + "commit.txt") -type file -Value $Mensaje_Commit 

Write-Host "Copiado éxitoso" -ForegroundColor Green