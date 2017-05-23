#ruta archivo Warmup
$ruta = '';

$TareaTrigger = New-ScheduledTaskTrigger -Daily -At '6AM';
$TareaNombre = "WarmUp Sharepoint";
$Tarea = New-ScheduledTaskAction -Execute "powershell.exe" -File $ruta;
$TareaConfiguracion = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -ExecutionTimeLimit ([TimeSpan]::Zero)
$TareaPrincipal = New-ScheduledTaskPrincipal -User "Dominio\Usuario" -RunLevel "Highest"

Register-ScheduledTask $TareaNombre -Action $Tarea -Trigger $TareaTrigger -Principal $TareaPrincipal -Settings $TareaConfiguracion