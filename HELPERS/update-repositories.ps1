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
        Write-Host -ForegroundColor yellow "-- Removing 'gone' branches"

        foreach($goneBranch in $goneBranches)
        {
            git branch -D $goneBranch.split(" ", [StringSplitOptions]'RemoveEmptyEntries')[0]
        }
    }
}

function CheckWIPAndStash
{
    param([string] $status)

    if(![System.String]::IsNullOrWhiteSpace($status))
    {
        Write-Host -ForegroundColor yellow "-- WIP: stash"
        git stash --quiet
    }
}

function CheckWIPAndUnstash
{
    param([string] $status)

    if(![System.String]::IsNullOrWhiteSpace($status))
    {
        Write-Host -ForegroundColor yellow "-- WIP: stash pop"
        git stash pop --quiet
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
        
        $currentBranch = git branch --show-current

        $status = git status --porcelain
        
        CheckWIPAndStash -status $status

        Write-Host -ForegroundColor green "-- Updating"

        $masterBranch = git branch | Where-Object { $_.EndsWith("main") -or $_.EndsWith("master") }
        CheckBranchAndPull -branchToPull $masterBranch -currentBranch $currentBranch

        $devBranch = git branch | Where-Object { $_.EndsWith("dev") }
        if(![System.String]::IsNullOrWhiteSpace($devBranch))
        {
            CheckBranchAndPull -branchToPull $devBranch -currentBranch $currentBranch
        }

        RemoveGoneBranches
        
        $existCurrentBranch = git branch | Where-Object { $_.EndsWith($currentBranch) }
        if(![System.String]::IsNullOrWhiteSpace($existCurrentBranch))
        {
            git checkout $currentBranch --quiet
        }        

        CheckWIPAndUnstash -status $status
        
    }

    cd ..
}
