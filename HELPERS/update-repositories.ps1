function GetRightBranchName{
    param(
        [string] $branchName,
        [string] $commodinName = $null)

    $branch = $null;

    $branchPrincipal = git branch --list $branchName;

    if($branchPrincipal -ne $null)
    {
        $branch = $branchName;    
    }

    if($commodinName -ne $null -and $branchPrincipal -eq $null) 
    { 
        $branchCommodin  = git branch --list $commodinName; 

        if($branchCommodin -eq $null) 
        { 
            $branch = $commodinName;    
        }
    }

    return $branch;
}

function CheckBranchAndPull 
{
     param([string] $branchToPull)

    $currentBranch = git rev-parse --abbrev-ref HEAD;

    if($branchToPull -ne $null -and [System.String]::Compare($currentBranch, $branchToPull) -ne 0)
    {
        Write-Host -ForegroundColor green $branchToPull;
        git checkout $branchToPull
    }

    git pull
}

$folders = Get-ChildItem . -Directory

foreach ($folder in $folders) 
{
    cd $folder.Name

    if(Get-ChildItem . -Directory -Hidden | Where-Object { $_.Name -eq '.git' })
    {
        git fetch --prune

        $status = git diff --name-only
        if([System.String]::IsNullOrWhiteSpace($status))
        {
            Write-Host -ForegroundColor green "Updating $($folder.Name)"

            $branchToPull = GetRightBranchName -branchName 'main' -commodinName 'master'
            CheckBranchAndPull -branchToPull $branchToPull

            $branchToPull = GetRightBranchName -branchName 'dev'
            CheckBranchAndPull -branchToPull $branchToPull
        }
    }

    cd ..
}