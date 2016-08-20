Add-PSSnapin "Microsoft.SharePoint.Powershell"
$solutionName="" 
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$solutionPath = Join-Path ($scriptPath) $SolutionName
$solution = Get-SPSolution | ?{$_.Name -eq $solutionName}

if ($solution -ne $null )
{
    if ($solution.Deployed )
    {
        echo "Desinstalando solucion"
        Uninstall-SPSolution $solution.Name  -Confirm:$false
	    $mensaje= "."
        while ( $solution.JobExists )
        {
	        $mensaje= $mensaje+"."
            write-host  "$mensaje"        
            sleep 4
        }
	
	    echo "Removiendo solucion..."
        Remove-SPSolution $solution.Name -Confirm:$false	
    }else
    {
     Remove-SPSolution $solution.Name -Confirm:$false 
    }
}
echo "Instalando solucion $solutionName"

Add-SPSolution -LiteralPath $solutionPath
