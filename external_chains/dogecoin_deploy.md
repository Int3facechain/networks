# Testnet

1. Download the binaries, extract to the bin folder

```sh
wget https://github.com/dogecoin/dogecoin/releases/download/v1.14.7/dogecoin-1.14.7-x86_64-linux-gnu.tar.gz
tar -xzvf dogecoin-1.14.7-x86_64-linux-gnu.tar.gz
mv dogecoin-1.14.7/bin/* ~/bin/

# We can remove these
rm -rf dogecoin-1.14.7 dogecoin-1.14.7-x86_64-linux-gnu.tar.gz
```

2. Create home dir for dogecoin

```sh
mkdir ~/.dogecoin
```

3. Initialize configuration, set your own `rpcuser` and `rpcpassword`

```sh
echo 'daemon=1
server=1
testnet=1
listen=1
rpcconnect=127.0.0.1
rpcuser=dogecoinrpc
rpcpassword=CCwXB6IxXcYMlBd6w812yfmiahxYBnlR0KLlvMIjgOrGq9eqgj9WmdeTCSDVo4w9
paytxfee=0.01' > ~/.dogecoin/dogecoin.conf
```

4. Start the node

```sh
dogecoind
```

5. Verify the node is started

```sh
dogecoin-cli getinfo
```

You should see a response like this:

```json
{
  "version": 1140700,
  "protocolversion": 70015,
  "walletversion": 130000,
  "balance": 0.00000000,
  "blocks": 55054,
  "timeoffset": 0,
  "connections": 8,
  "proxy": "",
  "difficulty": 0.0005981929943754981,
  "testnet": true,
  "keypoololdest": 1715596527,
  "keypoolsize": 100,
  "paytxfee": 0.01000000,
  "relayfee": 0.00100000,
  "errors": ""
}
```

# Regtest

Alternative way is to create our own `regtest` network.

Everything is the same, but we should set different `dogecoin.conf` configuration:

```
daemon=1
server=1
regtest=1
listen=1
rpcconnect=127.0.0.1
rpcuser=dogecoinrpc
rpcpassword=CCwXB6IxXcYMlBd6w812yfmiahxYBnlR0KLlvMIjgOrGq9eqgj9WmdeTCSDVo4w9
paytxfee=0.01

addnode=...
addnode=...
```

Define addresses of all other nodes in `addnode` field. Default P2P port for regtest is `18444`.

1. Mine first blocks

```sh
dogecoin-cli generate 110
[
  "ad3c340e804e0b08af4b3302613b8f8f02ad7b4ea1cb2267e296868ee9705027",
  ...
]
```

2. Verify blocks are mined

```sh
dogecoin-cli getblockcount
110
```
You can do the same on the other nodes, to verify P2P connection.

3. Check the balance on our node

```sh
dogecoin-cli getbalance
35000000.00000000
```