<# 
.SYNOPSIS
  Script que ayuda a crear un arbol de carpetas necesarias para un proyecto de desarrollo
.NOTES 
    File Name      : CrearArbolCarpetasProyecto.ps1  
    Author         : Juan Esteban Yarce Carmona (https://github.com/JuanEstebanYC)
#>

$RUTAPARCIAL = "D:\\";
$NOMBREPROYECTO = "PRUEBA DESARROLLO";
$RUTACOMPLETA = "$RUTAPARCIAL$NOMBREPROYECTO";
$CARPETAS = @("CODIGO","DOCUMENTACION","ENTREGAS","PRUEBAS");

if(!(Test-Path -Path $RUTACOMPLETA)){
    New-Item -ItemType directory -Path $RUTA
    cd $RUTA
    foreach($CARPETA in $CARPETAS){
       New-Item -ItemType directory -Name $CARPETA; 
    }

}else{
    Write-Host "La carpeta ya existe y no se puede crear" -ForegroundColor Red
}