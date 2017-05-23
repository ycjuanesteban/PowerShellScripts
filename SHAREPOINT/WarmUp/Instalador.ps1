#ruta archivo Warmup
$ruta = 'C:\SPUtilities\WarmUp\WarmUp.ps1';

$TareaTrigger = New-ScheduledTaskTrigger -Daily -At '6AM';
$TareaNombre = "WarmUp Sharepoint";
$Tarea = New-ScheduledTaskAction -Execute "powershell.exe" -File $ruta;
$TareaConfiguracion = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -ExecutionTimeLimit ([TimeSpan]::Zero)
$TareaPrincipal = New-ScheduledTaskPrincipal -User "INTERGRUPO\adminfcaf2" -RunLevel "Highest"

Register-ScheduledTask $TareaNombre -Action $Tarea -Trigger $TareaTrigger -Principal $TareaPrincipal -Settings $TareaConfiguracion