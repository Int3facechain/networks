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

Then, check out the last released version. Currently, it's `v0.2.7`.

```bash
cd int3face-bridge
git checkout v0.2.7
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
int3faced init <your_moniker> --chain-id=int3face-1
```

### Download genesis
Download the `genesis.json` file and place it into the Int3face configuration directory (`~/.int3faced/config` by default).
```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3face-1/genesis.json --output-document $HOME/.int3faced/config/genesis.json
```

### Download app config
Download the `config.toml` file and place it into the Int3face configuration directory (`~/.int3faced/config` by default).
```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3face-1/config.toml --output-document $HOME/.int3faced/config/config.toml
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
1. https://docs.cometbft.com/v0.38/core/state-sync
2. https://docs.cosmos.network/main/user/run-node/run-node#state-sync

#### Download and Run update_trust.sh script

```shell
wget https://raw.githubusercontent.com/Int3facechain/networks/main/int3face-1/update_trust.sh -O update_trust.sh && chmod +x update_trust.sh && ./update_trust.sh
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
int3faced tendermint show-validator
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
  --amount=10000000uint3 \
  --chain-id="int3face-1" \
  --moniker="{your_moniker}" # replace it \ 
  --website="https://validator.website.io/" # replace it \
  --details="Validator info" # replace it \ 
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