function GetRightBranchName{
    param(
        [string] $branchName,
        [string] $commodinName = $null)

    $branch = $null;

    $branchPrincipal = git branch -a --list *$branchName*;

    if($branchPrincipal -ne $null)
    {
        $branch = $branchName;    
    }

    if($commodinName -ne $null -and $branchPrincipal -eq $null) 
    { 
        $branchCommodin = git branch -a --list *$commodinName*;
        
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
        git checkout $branchToPull --quiet
    }

    Write-Host -ForegroundColor green "--- Pulling: $branchToPull";
    git pull --quiet
}

$folders = Get-ChildItem . -Directory

foreach ($folder in $folders) 
{
    cd $folder.Name

    if(Get-ChildItem . -Directory -Hidden | Where-Object { $_.Name -eq '.git' })
    {
        Write-Host -ForegroundColor green "`nGit fetch -> $($folder.Name)"
        git fetch --prune --quiet

        Write-Host -ForegroundColor green "Removing 'gone' branches"
        git branch -vv | where {$_ -match '\[origin/.*: gone\]'} | foreach { git branch -D $_.split(" ", [StringSplitOptions]'RemoveEmptyEntries')[0]}

        $status = git diff --name-only
        if([System.String]::IsNullOrWhiteSpace($status))
        {
            Write-Host -ForegroundColor green "-- Updating"

            $branchToPull = GetRightBranchName -branchName 'main' -commodinName 'master'
            CheckBranchAndPull -branchToPull $branchToPull

            $branchToPull = GetRightBranchName -branchName 'dev'
            if(![System.String]::IsNullOrWhiteSpace($branchToPull))
            {
                CheckBranchAndPull -branchToPull $branchToPull
            }
        }
        else {
            Write-Host -ForegroundColor red "-- WIP in this repository"
        }
    }

    cd ..
}
