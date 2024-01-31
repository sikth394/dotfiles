|Symbol|Meaning|Source|
|---|---|---|
|`feature`|current branch; replaced with `#tag` or `@commit` if not on a branch|`git status --ignore-submodules=dirty`|
|`master`|remote tracking branch; only shown if different from local branch|`git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`|
|`wip`|the latest commit's summary contains "wip" or "WIP"|`git show --pretty=%s --no-patch HEAD`|
|`=`|up to date with the remote (neither ahead nor behind)|`git rev-list --count HEAD...@{upstream}`|
|`⇣42`|this many commits behind the remote|`git rev-list --right-only --count HEAD...@{upstream}`|
|`⇡42`|this many commits ahead of the remote|`git rev-list --left-only --count HEAD...@{upstream}`|
|`⇠42`|this many commits behind the push remote|`git rev-list --right-only --count HEAD...@{push}`|
|`⇢42`|this many commits ahead of the push remote|`git rev-list --left-only --count HEAD...@{push}`|
|`*42`|this many stashes|`git stash list`|
|`merge`|repository state|`git status --ignore-submodules=dirty`|
|`~42`|this many merge conflicts|`git status --ignore-submodules=dirty`|
|`+42`|this many staged changes|`git status --ignore-submodules=dirty`|
|`!42`|this many unstaged changes|`git status --ignore-submodules=dirty`|
|`?42`|this many untracked files|`git status --ignore-submodules=dirty`|
|`─`|the number of staged, unstaged or untracked files is unknown|`echo $POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY` or `git config --get bash.showDirtyState`|