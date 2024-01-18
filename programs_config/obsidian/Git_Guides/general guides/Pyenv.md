

### Using pyenv: 

```md 
pyenv install -v <version>

pyenv virtualenv <version> <env_name>

pyenv virtualenv 3.6.13 driver-fleet-optimizer

pyenv activate <env_name>

Pyenv local <env_name> (optional)
```
---

### list available python versions

```md
pyenv install --list
```

### install a specific python version

```md
pyenv install <desired_version>
```

---

### Check which version is active:  

```md
Pyenv version  
``` 
---

### check available versions:
  
```md
Pyenv versions
```
---
  
### IMPORTANT - verify that both:  
- Project Interperter  
- ’run configuration’ Interperter

  
Both use the python of the virtual env you have created, located here: 

```md
~/.pyenv/versions/<env_name>/bin/python
```  
---
  
### Then start installing dependencies :
  
```md
pip install -r requirements.txt
```
  

To install packages from via add this at the 1st line of  `requirements.txt` :  
  
```md
--extra-index-url https://repo.fury.io/KJaYyn3FPgywzzxqjYs-/viatransportation
```
---  

### Deleting the Venv:
-  delete from 2 places - Navigate to : 

```md
~/.pyenv/versions
```

and 

```md
~/.pyenv/versions/<specific_python_version>/envs
```

- Then:
  
```md
rm -rf <env_name>
```

---

### upgrade pyenv 

```md
brew update && brew upgrade pyenv
```
---

### Tips:

- sometimes you may need to downgrade your pip version to a version that doesn't enforce fixing conflicts that are risen from the packages in the `requirements.txt` file. to do so, run :

	```md
	pip install pip==19.2.3
	```

- sometimes it looks like you've done everything right, but still installing requirements fails. If you see stuff related to `python 2.7`, close the terminal and re-open it. If you configured the virtualenv corectly with python `3.x.x`, it should work now (a sort of refresh )
---

###### links: [[Venv]]