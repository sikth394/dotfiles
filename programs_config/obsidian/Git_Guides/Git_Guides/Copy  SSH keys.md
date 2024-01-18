# 1 
go to root folder and `cd .ssh/`

---

# 2 

run `ls`
see if you have something like `id_ed25519`

if so run this command :

```md
tr -d '\n' < ~/.ssh/id_ed25519.pub | pbcopy
```

should work for any other public key you find in that folder 

---

# 3

now you can paste what you have in your clipboard to the desired slot in github/gitlab etc.. give your key a name and that's it 