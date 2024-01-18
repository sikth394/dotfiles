

## _Step 1_:  
First we need to configure a new venv to contain the appropriate packages we need for deployment. We’ll use pyenv for that :  

```md

pyenv install `<version>`

pyenv virtualenv `<version>` `<env_name>`

pyenv virtualenv 3.6.13 driver-fleet-optimizer

pyenv activate `<env_name>`

Pyenv local `<env_name>` (optional)  
```
	
Check that it worked with:  

```md
Pyenv version  
```

Deal with project interpreter, Your desired version should be under:  
~/.pyenv/versions`/<env_name>/`bin/  
  
Now run :


```md
pip install -r requirements.txt    
```
---

## _Step 2_:  
Refresh your aws creds with :  

```md
gimme-aws-creds --profile fleet_dev  
```  

      
OR 

```md
gimme-aws-creds --profile planx_dev
```



---
 
## _Step 3_:  
Open docker desktop app, wait for it to be running  
Deploy! (don't forget about node dependencies [^1]):  



```md
serverless deploy --region us-east-1 --stage dev --cluster us1 --privatecluster del-a-0
```

In dev region is always us1 and stage is always dev.
private cluster is according to [this](https://docs.google.com/spreadsheets/d/1vEwKPX2Ud01svSpj230thOAZa2BU-BB1aXuMlJIG81g/edit#gid=0)  

---

You may need to run these if the requirements are acting up : 
3.6 :
```md
#!/bin/zsh  
  
docker image pull lambci/lambda@sha256:f13d08c0cc6a4d2b4f13e25e8adfec0131bc1fd409245b782510b30534e81375  
docker image rm lambci/lambda:build-python3.6  
docker image tag 1cc17dfe99f8 lambci/lambda:build-python3.6
```
3.7:
```md
#!/bin/zsh  
  
docker image pull lambci/lambda@sha256:bc6209ec27072cc66dee2362db58af6a5f327fd0508390c705a0d7719b30b491  
docker image rm lambci/lambda:build-python3.7  
docker image tag 095146b98c72 lambci/lambda:build-python3.7
```
3.8:
```md
#!/bin/zsh  
  
docker image pull lambci/lambda@sha256:d944b5ae251d24a089c4cc8c889e861cca6ce0ea0da376c364eeebe9ea4cce58  
docker image rm lambci/lambda:build-python3.8  
docker image tag 91a48d7f8dd1 lambci/lambda:build-python3.8
```

--- 


## Delete The Stack

when done, check [[Delete private stacks]]

also check out this [^2] an this [^3] [^4] 

---

## links
[Jenkins job that does all of this (deploy)](https://jenkins.prod-viafleet-internal.com/jenkins/job/deploy-fleet-services-serverless/build?delay=0sec) 


[^1]: go to the bottom of the `serverless.yml` file and run `npm install <plugin name>` on each line under `plugins`. do the same for file `package.json` -> dependecies  OR -> run `npm install` instead
[^2]: [[Pyenv#Tips|downgrade pip to solve requirements conflicts ]]
[^3]: when getting:	 

	```md
		An error occurred: CodeDeployServiceRole - Policy arn:aws:iam::aws:policy/AWSLambdaFullAccess does not exist or is not attachable.	
	```
						
	
	be sure to update:

			"serverless-plugin-canary-deployments": "^0.6.0",
				
under `devDependencies` in `package.json`

[^4]: when deploying `planning-plan` deploy `fleet-dal` as well


