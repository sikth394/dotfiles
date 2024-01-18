#### Delete local branch 

````bash
git branch -d <localBranchName>
````
---

#### list all branches in local and remote

```bash
git branch -a
```

---

#### list all local branches

```bash
git branch 
```

---

#### list all remote branches
```bash
git branch -r
```


---

#### reset merge 
```bash
git reset --merge
```

---
#### abort merge

```bash
git merge --abort
```

--- 

#### create new branch off specific branch 

```md
git checkout -b <new branch> <specific branch>
```

---

#### checkout a remote branch

```md
git switch <remote_branch_name>
```

#### push a new local branch to remote

```md
git push -u origin <branch>
```

___
####  squash commits -> same branch 

^f3c6f4

##### 1
 `git log `-> see the number of commits we want to squash 

##### 2
  
```md
	git rebase -i HEAD~<number of commits to squash>
```

##### 3
  mark all the ones to squash with `s` leave the one to keep with `p` then `:wq`

##### 4
```bash
	git push --force
```
 
---

####  squash commits  -> different branch 

^1214ff

- `<feature_branch>` - the branch we've been working on 
```md
git checkout master
git checkout -b <feature_branch-squashed>
git merge --squash <feature_branch>
git commit
```

then
```md
git push origin <feature_branch-squashed>
```

and open the PR for `<feature_branch-squashed>`

---

#### rebase off master

```bash
git rebase master
```

^100499


---

#### revert last commit (NOT saving changes) NOT ON SHARED BRANCHES ❗ 

```bash
git reset --hard HEAD~1
```

##### then push to remote
```bash
git push origin <branch_name> -f 
```

 
---


#### cherry pick commits
```md
git cherry-pick <commitSha>
```


---

#### revert last commit (keeping changes, making them `uncommited`)

```bash
git reset --soft HEAD~1
```

---

#### undo a git reset

```md
git reset 'HEAD@{1}'
```

---

#### unstage changes

```bash
git restore --staged <file>
```

---

#### stash changes

```bash
git stash
```


---

#### pop changes

```bash
git stash pop
```

--- 

