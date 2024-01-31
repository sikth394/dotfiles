```md
export CRYPTOGRAPHY_SUPPRESS_LINK_FLAGS="1"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
pip install cryptography==3.4.7
```
