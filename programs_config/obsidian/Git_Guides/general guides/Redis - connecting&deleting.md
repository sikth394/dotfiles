## use CLI
```md
redis-cli -h <REDIS_ENDPOINT> 
keys *
keys *<tenant_id>*
del <key1> <key2>
```

- `<REDIS_ENDPOINT>` - taken from env vars in aws -> lambda (plan has it) 
- `example`:
 ```md
fle-pl-1hxxegdr4y94w.uwuyrs.0001.use1.cache.amazonaws.com 
```


## use python console
```py
from redis import Redis 
redis_client = Redis("<REDIS_ENDPOINT>" ,port = 6379 ,password = None, ssl=False)
x = redis_client.keys()
```
(play with `ssl=False` if not working)
#### to clear all keys:

```md
redis_client.flushall()
```
(be minded, do it in privatecluster but not in dev)



