#SCRIPT QUE HACE UNA COPIA DEL FORLDER DESIGNADO EN $RutaOrigen
$DEBUG = 1

#MENSAJE A GUARDAR EN EL ARCHIVO commit.txt
$Mensaje_Commit = ""

#VARIABLES REQUERIDAS
$RutaOrigen = 'RUTA_ORIGEN'
$RutaDestino = "RUTA_DESTINO"
$Fecha = (Get-Date -Format u).Split(' ')[0].Replace('-','')
$RutaDestinoFecha = $($RutaDestino) + $($Fecha) 

if($DEBUG = 1){
    Write-Host "DEBUG" -ForegroundColor Red
    Write-Host $RutaOrigen -ForegroundColor Yellow
    Write-Host $RutaDestinoFecha -ForegroundColor Yellow
}

#VERIFICA SI EXISTE LA CARPETA DEL DÍA ACTUAL, DE NO EXISTIR LA CREA
if(!(Test-Path -Path $RutaDestinoFecha )){
    New-Item -ItemType directory -Path $RutaDestinoFecha
}

#COPIA LAS CARPETAS DEL ORIGEN AL DESTINO
Write-Host "Copiando los archivos" -ForegroundColor Green
Copy-Item  $RutaOrigen  $RutaDestinoFecha -Recurse

#CREA EL ARCHIVO commit.txt Y GUARDA EL TEXTO DE LA VARIABLE $Mensaje_Commit
Write-Host "Creando archivo commit" -ForegroundColor Green
New-Item $($RutaDestinoFecha + "\commit.txt") -type file -Value $Mensaje_Commit

Write-Host "Copiado éxitoso" -ForegroundColor Green