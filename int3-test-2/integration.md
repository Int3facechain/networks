# Setting up an Int3face validator

## Hardware

We recommend selecting an all-purpose server with:

* 4 or more physical (or 8 virtual) CPU cores
* At least 500GB of SSD disk storage
* At least 16GB of memory
* At least 100mbps network bandwidth

The usage of the blockchain grows, plus it may be needed to bootstrap external chain nodes, so the server requirements may increase as well, so you should have a plan for updating your server as well.

## Prerequisites

### Golang

This project requires Go version 1.22 or later. Install Go by following the instructions on the official [Go installation guide](https://go.dev/doc/install).

#### Linux installation

Install the latest version of Golang
```shell
wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
```

Remove any previous Go installation and install the new version
```shell
 rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
```

Add `/usr/local/go/bin` to the `PATH` environment variable.
You can do this by adding the following line to your `$HOME/.profile` or `/etc/profile` (for a system-wide installation):
```shell
export PATH=$PATH:/usr/local/go/bin
```

Verify that you've installed Go by opening a command prompt and typing the following command
```shell
go version
```

### Build essential

Install essential tools and packages needed to compile and build the binaries.

```bash
sudo apt update && sudo apt upgrade -y
```
```bash
sudo apt install build-essential -y
```

## Int3face node

### Build and install the binary

Int3face node provides CLI commands for submitting inbound and outbound transfers and other queries.

To install Int3face node, clone the repository to your local machine from Github. Please contact the Int3face team for accessing the `Int3facechain/bridge` repository.

```bash
git clone https://github.com/Int3facechain/bridge.git int3face-bridge
```

Then, check out the last released version. Currently, it's `v0.2.6`.

```bash
cd int3face-bridge
git checkout v0.2.6
```

At the top-level directory of the project execute the following command, which will build and install the `int3faced` binary to `$GOPATH/bin`.

```bash
make install
```

### Verify the installation

```shell
int3faced version --long
```

### Initialize node

Use `int3faced` to initialize your node (replace the `<your_moniker>` with a name of your choosing):

```bash
int3faced init <your_moniker> --chain-id=int3-test-2
```

### Download genesis
Download the `genesis.json` file and place it into the Int3face configuration directory (`~/.int3faced/config` by default).
```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/genesis.json --output-document $HOME/.int3faced/config/genesis.json
```

### Download app config
Download the `config.toml` file and place it into the Int3face configuration directory (`~/.int3faced/config` by default).
```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/config.toml --output-document $HOME/.int3faced/config/config.toml
```

The next step is to set your moniker in `config.toml` instead of the default one. You can do it by modifying the `moniker` field at the top of the `config.toml` file.

Besides that, you can modify the config if it's needed, but make sure to keep all the default ports and persistent peer addresses.

### Import validator key

You can either create a new key for your validator or import an existing key.

#### Create new
```shell
int3faced keys add <key_name>
```
Don't forget to save the mnemonic!

#### Import existing
```shell
int3faced keys add <key_name> --recover
```

### Sync the node

We use a state snapshot to sync the state of the node. For state syncing, the `config.toml` file must be properly set, which is already done if you use the config from this repo. If you want to know more about this process, feel free to refer to the documentation
1. https://docs.cometbft.com/v0.37/core/state-sync
2. https://docs.cosmos.network/main/user/run-node/run-node#state-sync

#### Download and Run update_trust.sh script

```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/update_trust.sh -O update_trust.sh && chmod +x update_trust.sh && ./update_trust.sh
```

### Start the node
The following command starts the node. Note that after starting, the node should sync first, which may take some time until you can start using it.
```shell
int3faced start
```

### Top up the account

Contact the Int3face team and provide your validator's account address to top it up.

### Get your Tendermint validator public key

Firstly, you need to get your Tendermint validator public key. You must get is as it will be necessary to include in the transaction to create your validator.

If you are using Tendermint's native `priv_validator.json` as your consensus key, you display your validator public key using the following command.
```shell
int3faced comet show-validator
```

The output looks like this
```shell
{"@type":"/cosmos.crypto.ed25519.PubKey","key":"w/YfkzNivDZ34y+mbK3/j3WWgYao18tBLf4Ypm2okCU="}
```

### Submit validator creation

Now that you have you key imported, you are able to use it to create the validator.

To create the validator, you will have to choose the following parameters for your validator:

* moniker
* commission-rate
* commission-max-rate
* commission-max-change-rate
* min-self-delegation (must be >1)
* website (optional)
* details (optional)
* pubkey (gotten in previous step)

If you would like to override the memo field, use the `--ip` and `--node-id` flags.

An example `create-validator` command looks like this:
```shell
int3faced tx staking create-validator \
  --from=my_validator \
  --amount=1000000uint3 \
  --chain-id="int3-test-2" \
  --moniker="{your_moniker}" # replace it \ 
  --website="https://int3face.io/" \
  --details="Int3face lover" \
  --commission-rate="0.1" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --pubkey='{"@type":"/cosmos.crypto.ed25519.PubKey","key":"w/YfkzNivDZ34y+mbK3/j3WWgYao18tBLf4Ypm2okCU="}' # replace it
```

### Start a background service

You will need some way to keep the `int3faced start` process always running. If you're on linux, you can do this by creating a service.

```shell
sudo tee /etc/systemd/system/int3faced.service > /dev/null <<EOF  
[Unit]
Description=Int3face Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which int3faced) start
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_HOME=$HOME/.int3faced/"
Environment="DAEMON_NAME=int3faced"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

StandardOutput=append:$HOME/.int3faced/logs/int3faced.log
StandardError=append:$HOME/.int3faced/logs/int3faced-error.log
SyslogIdentifier=int3faced

[Install]
WantedBy=multi-user.target
EOF
```

Service's logs are stored into the `$HOME/.int3faced/logs/` directory.

Then update and start the node:
```shell
sudo -S systemctl daemon-reload
sudo -S systemctl enable int3faced
sudo -S systemctl start int3faced
```

You can check the status with:
```shell
sudo -S systemctl status int3faced
```

And disable, stop, or restart the service:
```shell
sudo -S systemctl disable int3faced
sudo -S systemctl stop int3faced
sudo -S systemctl restart int3faced
```

Logs are available using the following command:
```shell
sudo journalctl -u int3faced
```

## Observer node

### Build and install the binary

Int3face observer provides block scanners and chain clients for Int3face and external chains.

To install Int3face observer, clone the repository to your local machine from Github. Please contact the Int3face team for accessing the `Int3facechain/observer` repository.

```bash
git clone https://github.com/Int3facechain/observer.git int3face-int3obsd
```

Then, check out the last released version. Currently, it's `v0.2.1`.

```bash
cd int3face-int3obsd
git checkout v0.2.1
```

At the top-level directory of the project execute the following command, which will build and install the `int3obsd` binary to `$GOPATH/bin`.

```bash
make install
```
This command builds and installs the `int3obsd` binary to `$GOPATH/bin`.

NOTE: if you have problem with access to the bridge go module, try to use GOPRIVATE environment variable: `export GOPRIVATE=github.com/Int3facechain/*`

### Init the observer

After that, `int3obsd` can be used to initialize the configuration.
```bash
int3obsd init
```
This creates the observer configuration in the Int3face home directory (`~/.int3faced` by default) with the following folders:
```text
observer
└── default
    ├── tss
    ├── logs
    ├── node_key
    ├── node_key.pub
    ├── observer.toml
    ├── pool_key.pub
    └── pre_params.hex
```

The `default` folder stores the current observer profile; refer to [Profiles](#profiles) for details. The profile folder contents:
1. `tss` is a folder with all TSS-related information
2. `logs` is a folder for logs
3. `node_key` is the node's private key
4. `node_key.pub` is the node's public key
5. `observer.toml` is the observer config file
6. `pool_key.pub` is the current public key of the committee
7. `pre_params.json` is the hexed pre-parameters used for the key generation

All the files and folders contain randomly generated data, which is sufficient for launching the node. Please do not modify these files unless you know what you are doing!

### Download observer config

Download the `observer.toml` file and place it into the observer configuration directory (`~/.int3faced/observer/default` by default).
```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/observer.toml --output-document $HOME/.int3faced/observer/default/observer.toml
```

Modify the config if it's needed. The most important thing is to ensure that the `keyring-folder` parameter is properly configured and points to your keyring. Note that in some Linux distributions, the observer binary fails to parse a tilde sign in the home-relative path. Therefore, if you receive an error saying that the keyring is not found, try changing the keyring path in `observer.toml` from, for example, `~/.intrfaced` to `/root/.intrfaced` (meaning avoid using `~`).

### Start the observer

Start the observer using your validator's account.
```bash
int3obsd start --from <key_name>
```

You will need some way to keep the `int3obsd start` process always running. If you're on linux, you can do this by creating a service.

To make the service work, you need a way to pass your keyring passphrase to the service. One option to do that is to create an environment variable with your passphrase and make it persistent for the current linux user.

```shell
echo 'export PASSPHRASE="<your_keyring_passphrase>"' | tee -a .profile
```

And to load changes type
```shell
source .profile
```

This command will add a new variable called `PASSPHRASE` and persist it in your bash config. Later, the observer service will use it to start automatically.

```shell
sudo tee /etc/systemd/system/int3obsd.service > /dev/null <<EOF  
[Unit]
Description=Int3face Observer Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/sh -c 'echo ${PASSPHRASE} | $(which int3obsd) start --from my_validator_2'
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_HOME=$HOME/.int3faced/observer"
Environment="DAEMON_NAME=int3obsd"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

StandardOutput=append:$HOME/.int3faced/observer/default/logs/int3obsd.log
StandardError=append:$HOME/.int3faced/observer/default/logs/int3obsd-error.log
SyslogIdentifier=int3obsd

[Install]
WantedBy=multi-user.target
EOF
```

Service's logs are stored into the `$HOME/.int3faced/observer/default/logs/` directory.

Then update and start the node:
```shell
sudo -S systemctl daemon-reload
sudo -S systemctl enable int3obsd
sudo -S systemctl start int3obsd
```

You can check the status with:
```shell
sudo -S systemctl status int3obsd
```

And disable, stop, or restart the service:
```shell
sudo -S systemctl disable int3obsd
sudo -S systemctl stop int3obsd
sudo -S systemctl restart int3obsd
```

Logs are available using the following command:
```shell
sudo journalctl -u int3obsd
```

### Join the committee

At the beginning, your node is not part of the TSS committee. While you can observe blocks, your vote will not be counted during bridging. To become a participant, please wait for the next round of pool public key generation. If you want to expedite this process or require additional information, feel free to contact our team!

## DOGE Node

### Download binaries

Download the DOGE binaries and extract them to the bin folder.
```shell
wget https://github.com/dogecoin/dogecoin/releases/download/v1.14.7/dogecoin-1.14.7-x86_64-linux-gnu.tar.gz
tar -xzvf dogecoin-1.14.7-x86_64-linux-gnu.tar.gz
mv dogecoin-1.14.7/bin/* ~/bin/

# We can remove these
rm -rf dogecoin-1.14.7 dogecoin-1.14.7-x86_64-linux-gnu.tar.gz
```

`bin` folder is a folder added to the `PATH` environment variable. However, you can use an arbitrary folder to store the binaries.

If you also want to use the `bin` folder, one can be added to the `PATH` using the following command:

```shell
echo 'export PATH=$PATH:~/bin' | tee -a .profile
```

And to load changes type
```shell
source .profile
```

### Create home dir

```shell
mkdir ~/.dogecoin
```

### Download DOGE configuration
```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/dogecoin.conf --output-document $HOME/.dogecoin/dogecoin.conf
```
And set your own `rpcuser` and `rpcpassword` in the downloaded file. Also, modify these fields in the `observer.toml` file, so the observer can connect to the Dogecoin node.

### Start the node

```shell
dogecoind
```

### Verify the node is started

```shell
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

### Mine blocks

Mine blocks to collect new coins. You may need to execute this operation several times until you get the coins.

```shell
dogecoin-cli generate 110
```

110 is the number of the mined blocks, this may be an arbitrary number. Keep in mind, that Dogecoin has a maturity period of 100 blocks, this means that any mined tokens will be reflected in your balance only after 100 blocks.

Response:

```
[
  "ad3c340e804e0b08af4b3302613b8f8f02ad7b4ea1cb2267e296868ee9705027",
  ...
]
```

### Verify the blocks are mined

```shell
dogecoin-cli getblockcount
```

### Check the balance of our node

```shell
dogecoin-cli getbalance
```

## BTC Node

### Download binaries

```shell
wget https://bitcoincore.org/bin/bitcoin-core-25.0/bitcoin-25.0-x86_64-linux-gnu.tar.gz
tar -xzvf bitcoin-25.0-x86_64-linux-gnu.tar.gz
mv bitcoin-25.0/bin/* ~/bin/

rm -rf bitcoin-25.0  bitcoin-25.0-x86_64-linux-gnu.tar.gz
```

`bin` folder is a folder added to the `PATH` environment variable. However, you can use an arbitrary folder to store the binaries.

If you also want to use the `bin` folder, one can be added to the `PATH` using the following command:

```shell
echo 'export PATH=$PATH:~/bin' | tee -a .profile
```

And to load changes type
```shell
source .profile
```

### Create home dir

```shell
mkdir ~/.bitcoin
```

### Download BTC configuration

```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/bitcoin.conf --output-document $HOME/.bitcoin/bitcoin.conf
```

### Start the node

```shell
bitcoind
```

### Verify node is started

```shell
bitcoin-cli getblockchaininfo
```

You should see a response like this:

```json
{
  "chain": "regtest",
  "blocks": 115,
  "headers": 115,
  "bestblockhash": "49e631bd7f92343f2c3a74636821493770309993ba59abbf518da911f850917f",
  "difficulty": 4.656542373906925e-10,
  "time": 1718890479,
  "mediantime": 1718884754,
  "verificationprogress": 1,
  "initialblockdownload": false,
  "chainwork": "00000000000000000000000000000000000000000000000000000000000000e8",
  "size_on_disk": 38617,
  "pruned": false,
  "warnings": ""
}
```

### Create new wallet or load your own wallet

#### Create

```shell
bitcoin-cli createwallet "$your_wallet_name$" false false "" false true true
```

Args after the wallet name:
1. Enables use of the private keys
2. Init keys and HD seed
3. Password
4. Keep track of coin reuse
5. Create native descriptors
6. Load this wallet on startup

#### Load

```shell
bitcoin-cli loadwallet "$your_wallet_name$" true
```

Args after the wallet name:
1. Load this wallet on startup

### Create new address for your wallet

```shell
bitcoin-cli getnewaddress
```

### Mine blocks

```shell
bitcoin-cli generatetoaddress 110 $YOUR_ADDR$
```

110 is the number of the mined blocks, this may be an arbitrary number. Keep in mind, that Bitcoin has a maturity period of 100 blocks, this means that any mined tokens will be reflected in your balance only after 100 blocks.

### Verify the blocks are mined

```shell
bitcoin-cli getblockcount
```

### Check the balance of our node

```shell
bitcoin-cli getbalance
```

## BCH Node

### Download binaries

BCH binaries names intersect with the BTC names. So, we are going to rename the binaries.

```shell
wget https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v27.1.0/bitcoin-cash-node-27.1.0-x86_64-linux-gnu.tar.gz
tar -xzvf bitcoin-cash-node-27.1.0-x86_64-linux-gnu.tar.gz

mv bitcoin-cash-node-27.1.0/bin/bitcoind ~/bin/bcashd
mv bitcoin-cash-node-27.1.0/bin/bitcoin-cli ~/bin/bcash-cli
mv bitcoin-cash-node-27.1.0/bin/bitcoin-tx ~/bin/bcash-tx

rm -rf bitcoin-cash-node-27.1.0 bitcoin-cash-node-27.1.0-x86_64-linux-gnu.tar.gz
```

### Create home dir

```shell
mkdir ~/.bitcoin-cash
```

### Download BCH configuration

wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/bitcoin-cash.conf --output-document $HOME/.bitcoin-cash/bitcoin-cash.conf

### Create aliases

Since the BCH names and paths conflict with the BTC, let's create aliases for the main BCH binaries.

```shell
echo "alias bcashd='bcashd -conf=$HOME/.bitcoin-cash/bitcoin-cash.conf -datadir=$HOME/.bitcoin-cash'" | tee -a .profile

echo "alias bcash-cli='bcash-cli -conf=$HOME/.bitcoin-cash/bitcoin-cash.conf'" | tee -a .profile
```

And to load changes type
```shell
source .profile
```

### Start the node

```shell
bcashd
```

### Verify node is started

```shell
bcash-cli getblockchaininfo
```

You should see a response like this:

```json
{
  "chain": "regtest",
  "blocks": 0,
  "headers": 0,
  "bestblockhash": "0f9188f13cb7b2c71f2a335e3a4fc328bf5beb436012afca590b1a11466e2206",
  "difficulty": 4.656542373906925e-10,
  "mediantime": 1296688602,
  "verificationprogress": 1,
  "initialblockdownload": true,
  "chainwork": "0000000000000000000000000000000000000000000000000000000000000002",
  "size_on_disk": 293,
  "pruned": false,
  "warnings": ""
}
```

### Create new address for your wallet

```shell
bcash-cli getnewaddress
```

### Mine blocks

```shell
bcash-cli generatetoaddress 110 $YOUR_ADDR$
```

110 is the number of the mined blocks, this may be an arbitrary number. Keep in mind, that Bitcoin has a maturity period of 100 blocks, this means that any mined tokens will be reflected in your balance only after 100 blocks.

### Verify the blocks are mined

```shell
bcash-cli getblockcount
```

### Check the balance of your node

```shell
bcash-cli getbalance
```

## LTC Node

### Download binaries

```shell
wget https://download.litecoin.org/litecoin-0.21.3/linux/litecoin-0.21.3-x86_64-linux-gnu.tar.gz
tar -xzvf litecoin-0.21.3-x86_64-linux-gnu.tar.gz
mv litecoin-0.21.3/bin/* ~/bin/

rm -rf litecoin-0.21.3 litecoin-0.21.3-x86_64-linux-gnu.tar.gz
```

`bin` folder is a folder added to the `PATH` environment variable. However, you can use an arbitrary folder to store the binaries.

If you also want to use the `bin` folder, one can be added to the `PATH` using the following command:

```shell
echo 'export PATH=$PATH:~/bin' | tee -a .profile
```

And to load changes type
```shell
source .profile
```

### Create home dir

```shell
mkdir ~/.litecoin
```

### Download LTC configuration

```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3-test-2/litecoin.conf --output-document $HOME/.litecoin/litecoin.conf
```

### Start the node

```shell
litecoind
```

### Verify node is started

```shell
litecoin-cli getblockchaininfo
```

You should see a response like this:

```json
{
  "chain": "regtest",
  "blocks": 0,
  "headers": 0,
  "bestblockhash": "530827f38f93b43ed12af0b3ad25a288dc02ed74d6d7857862df51fc56c416f9",
  "difficulty": 4.656542373906925e-10,
  "mediantime": 1296688602,
  "verificationprogress": 1,
  "initialblockdownload": true,
  "chainwork": "0000000000000000000000000000000000000000000000000000000000000002",
  "size_on_disk": 288,
  "pruned": false,
  "softforks": {
    "bip34": {
      "type": "buried",
      "active": false,
      "height": 500
    },
    "bip66": {
      "type": "buried",
      "active": false,
      "height": 1251
    },
    "bip65": {
      "type": "buried",
      "active": false,
      "height": 1351
    },
    "csv": {
      "type": "buried",
      "active": false,
      "height": 432
    },
    "segwit": {
      "type": "buried",
      "active": true,
      "height": 0
    },
    "testdummy": {
      "type": "bip9",
      "bip9": {
        "status": "defined",
        "start_time": 0,
        "timeout": 9223372036854775807,
        "since": 0
      },
      "active": false
    },
    "taproot": {
      "type": "bip9",
      "bip9": {
        "status": "active",
        "start_time": -1,
        "timeout": 9223372036854775807,
        "since": 0
      },
      "height": 0,
      "active": true
    },
    "mweb": {
      "type": "bip9",
      "bip9": {
        "status": "defined",
        "start_time": 1601450001,
        "timeout": 9223372036854775807,
        "since": 0
      },
      "active": false
    }
  },
  "warnings": ""
}
```

### Create new wallet

```shell
litecoin-cli createwallet "observer" false false "" false true true 
```

Args after the wallet name:
1. Enables use of the private keys
2. Init keys and HD seed
3. Password
4. Keep track of coin reuse
5. Create native descriptors
6. Load this wallet on startup

Use the name "observer" for the wallet, as it's required by the observer node

### Create new address for your wallet

```shell
litecoin-cli getnewaddress
```

### Mine blocks

```shell
litecoin-cli generatetoaddress 110 $YOUR_ADDR
```

110 is the number of the mined blocks, this may be an arbitrary number. Keep in mind, that Litecoin has a maturity period of 100 blocks, this means that any mined tokens will be reflected in your balance only after 100 blocks.

### Verify the blocks are mined

```shell
litecoin-cli getblockcount
```

### Check the balance of your node

```shell
litecoin-cli getbalance
```