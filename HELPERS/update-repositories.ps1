function CheckBranchAndPull 
{
    param(
        [string] $branchToPull,
        [string] $currentBranch
    )

    if($branchToPull -match "\*")
    {
        $branchToPull = $branchToPull.split(" ", [StringSplitOptions]'RemoveEmptyEntries')[1]
    }

    $branchToPull = $branchToPull.Trim()

    if($branchToPull -ne $null -and [System.String]::Compare($currentBranch, $branchToPull) -ne 0)
    {
        git checkout $branchToPull --quiet
    }

    Write-Host -ForegroundColor green "--- Pulling: $branchToPull";
    git pull --quiet
}

function RemoveGoneBranches
{
    $goneBranches = git branch -vv | where {$_ -match '\[origin/.*: gone\]'}

    if($goneBranches -ne $null)
    {
        Write-Host -ForegroundColor green "Removing 'gone' branches"

        foreach($goneBranch in $goneBranches)
        {
            git branch -D $goneBranch.split(" ", [StringSplitOptions]'RemoveEmptyEntries')[0]
        }
    }
}

$folders = Get-ChildItem . -Directory

foreach ($folder in $folders) 
{
    cd $folder.Name

    if(Get-ChildItem . -Directory -Hidden | Where-Object { $_.Name -eq '.git' })
    {
        Write-Host -ForegroundColor green "`nGit updating -> $($folder.Name)"
        git fetch --prune --quiet
        
        $currentGitBranch = git branch --show-current

        $status = git status --porcelain
        if(![System.String]::IsNullOrWhiteSpace($status))
        {
            Write-Host -ForegroundColor yellow "-- WIP: stagin work"
            git stash --quiet
        }

        Write-Host -ForegroundColor green "-- Updating"

        $branchToPull = git branch | Where-Object { $_.EndsWith("main") -or $_.EndsWith("master") }
        CheckBranchAndPull -branchToPull $branchToPull -currentBranch $currentGitBranch

        $branchToPull = git branch | Where-Object { $_.EndsWith("dev") }
        if(![System.String]::IsNullOrWhiteSpace($branchToPull))
        {
            CheckBranchAndPull -branchToPull $branchToPull -currentBranch $currentGitBranch
        }

        RemoveGoneBranches

        if(![System.String]::IsNullOrWhiteSpace($status))
        {
            Write-Host -ForegroundColor yellow "-- WIP: checking out to the branch"
            git checkout $currentGitBranch
            git stash pop --quiet
        }
    }

    cd ..
}
