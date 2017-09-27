$hostheader = "URL"
$rutaBackup = "RUTA BACKUP";
$puertoBase = 0000;
$puertoDestino = 0000;
$nombreBD = "NOMBRE DB";
$nombreServidorBD = "SERVIDOR/ALIAS";
$owner = "DOMINIO\USUARIO";
$nombreBDDestino = "";
$nombreAppBase = "URL WEB APP BASE";
$nombreAppDestino = "URL WEB APP DESTINO";

Add-PSSnapin "Microsoft.SharePoint.Powershell" -ErrorAction SilentlyContinue

function Get-SPContentDatabaseByName($name, $webApp){
   $db =  Get-SPContentDatabase -webApplication $webApp | ? {$_.Name -eq $name};
   return $db;
}

function Set-LogTimer($message){
    "[$(Get-Date -format g)] $message"
}

function Convert-PathToHNSC($hostheader,$rutaBackup,$puertoBase,$nombreBD,$nombreServidorBD,$owner){
    #inicia proceso general  de migración otros portales

    #inicialización
    $webAppBase = "http://$nombreAppBase" + ":$puertoBase";
    $webAppDestino = "http://$nombreAppDestino" + ":$puertoDestino";
    #Inicia proceso de migración

    #migración de datos
    Write-Host "Inicia migración, esta operación puede tardar varios minutos" -ForegroundColor Yellow;
    Write-Progress -Activity "Conversión del Sitio" -PercentComplet 0 -CurrentOperation "Migrando Base de Datos";
    Set-LogTimer -message "Migrando Base de Datos"
    
    $bdMigra = Get-SPContentDatabaseByName -name $nombreBD -webApp $webAppBase -ErrorAction Silence;
    if(!$bdMigra){
        $bdMigra = Mount-SPContentDatabase $nombreBD -DatabaseServer $nombreServidorBD -WebApplication $webAppBase -ErrorAction Stop -AssignNewDatabaseId;
    }
    Set-LogTimer -message "Fin Migrando Base de Datos"
    
    $web = Get-SPWeb (Get-SPSite -WebApplication $webAppBase -ErrorAction Stop)[0].Url -ErrorAction Stop;

    try{ 
        if($web -eq $null) { 
            $rutaBackup += "\AMigrar.bak"; 
        }
        else { 
            $rutaBackup += "\$web.bak"; 
        }
    }
    catch { $rutaBackup += "\AMigrar.bak";}
    
    #inicia proceso de conversión Path based to HNSC
    Write-Host "Inicio de conversión del sitio, esta operación puede tardar varios minutos" -ForegroundColor Yellow
    Write-Progress -Activity "Conversión del Sitio" -PercentComplet 20 -CurrentOperation "Extrayendo respaldo del sitio";

    #copia de respaldo del sitio
    Set-LogTimer -message "Extrayendo respaldo del sitio"
    $backup = Get-ChildItem -Path $rutaBackup -ErrorAction SilentlyContinue;
    if(!$backup){
        #Backup-SPSite $webAppBase -Path $rutaBackup -UseSqlSnapshot:$true -Force -ErrorAction Stop;
        Backup-SPSite $web.Url -Path $rutaBackup -UseSqlSnapshot:$true -Force -ErrorAction Stop;
    }
    Set-LogTimer -message "Fin Extrayendo respaldo del sitio"
   
    #eliminar sitio
    Write-Progress -Activity "Conversión del Sitio" -PercentComplet 40 -CurrentOperation "Eliminando sitio basado en ruta";
    Set-LogTimer -message "Eliminando sitio basado en ruta"
    $site = Get-SPSite -WebApplication $webAppBase -ErrorAction SilentlyContinue | ? {$_.Url -eq  $web.Url };

    if($site){
        Remove-SPSite -Identity $web.Url -Confirm:$false -ErrorAction Stop;
    }
    Set-LogTimer -message "Fin Eliminando sitio basado en ruta"
    
    #desasociar base de datos del web app base
    Write-Progress -Activity "Conversión del Sitio" -PercentComplet 60 -CurrentOperation "Desasociando base de datos";
    Set-LogTimer -message "Desasociando base de datos"
    $bdBase = Get-SPContentDatabaseByName -name $nombreBD -webApp $webAppBase;
    if($bdBase){
        Dismount-SPContentDatabase $nombreBD -Confirm:$false -ErrorAction Stop;
    }
     Set-LogTimer -message "Fin Desasociando base de datos"
    
    #asociar base de datos al web app destino
    Write-Progress -Activity "Conversión del Sitio" -PercentComplet 70 -CurrentOperation "Asociando Nueva base de datos";
    Set-LogTimer -message "Asociando Nueva base de datos"
    $bd = Get-SPContentDatabaseByName -name $nombreBD -webApp $webAppDestino;
    if(!$bd){
        $bd = Mount-SPContentDatabase $nombreBD -DatabaseServer $nombreServidorBD -WebApplication $webAppDestino -ErrorAction Stop -NoB2BSiteUpgrade -AssignNewDatabaseId;
    }
    Set-LogTimer -message "Fin Asociando Nueva base de datos"

    Write-Progress -Activity "Conversión del Sitio" -PercentComplet 80 -CurrentOperation "Restaurando el sitio";
    Set-LogTimer -message "Restaurando el sitio"
    $newsite = Get-SPSite  $hostheader -ErrorAction SilentlyContinue;
    if(!$newsite){
        $w = Get-SPWebApplication -identity $webAppDestino;
        $w.GrantAccessToProcessIdentity($owner);
        if($nombreBDDestino -eq [string]::Empty) {
            $nombreBDDestino = $nombreBD;
        }
        Write-Progress -Activity "Conversión del Sitio" -PercentComplet 90 -CurrentOperation "Restaurando el sitio";
        Restore-SPSite $hostheader -Path $rutaBackup -HostHeaderWebApplication $w.Url -ContentDatabase $nombreBDDestino -Confirm:$false -Force -ErrorAction Stop;
    }
    Set-LogTimer -message "Fin Restaurando el sitio"
    Write-Host "Conversión del sitio finalizada" -ForegroundColor Cyan;

    #fin conversión de sitio
    Write-Progress -Activity "Proceso finalizado" -PercentComplet 100 -CurrentOperation "Proceso finalizado";
    Write-Host "Proceso finalizado correctamente" -ForegroundColor Green;
}

Set-LogTimer -message "Inicio del proceso"
Convert-PathToHNSC -hostheader $hostheader -rutaBackup $rutaBackup -puertoBase $puertoBase -nombreBD $nombreBD -nombreServidorBD $nombreServidorBD -owner $owner;
Set-LogTimer -message "Fin del proceso"