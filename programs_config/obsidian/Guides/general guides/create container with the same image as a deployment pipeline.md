# 1
gimme-aws-creds to the relevant profile | log in with okta to the relevant profile (for example `gimme fleet_staging`)

# 2
login to aws ECR:

```md
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 205282831132.dkr.ecr.us-east-1.amazonaws.com
```

# 3
pull the relevant image with  

```md
docker image pull 205282831132.dkr.ecr.us-east-1.amazonaws.com/fleet-pipeline-image:$TAG
($TAG is the relevant image version we use in that specific pipeline)

```

# 4
run a local container  

```md
docker run \
--rm \
-it 205282831132.dkr.ecr.us-east-1.amazonaws.com/fleet-pipeline-image:$TAG \
bash
```
