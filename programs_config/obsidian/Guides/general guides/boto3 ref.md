```md
lambda_client = boto3.client("lambda")

response = lambda_client.invoke(FunctionName=lambda_name,                                        InvocationType="RequestResponse",                                            Payload=json.dumps(create_shift_request))
```

---

- check out `driver-fleet-shift-creator/clients/shift_client.py` function : `create_shift` for reference on invoking lambda with boto3