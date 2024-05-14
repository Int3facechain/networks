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
Remove any previous Go installation
```shell
 rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
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
sudo apt install build-essential
```

## Int3face node

### Build and install the binary

Int3face node provides CLI commands for submitting inbound and outbound transfers and other queries.

To install Int3face node, clone the repository to your local machine from Github. Please contact the Int3face team for accessing the `Int3facechain/briage` repository.

```bash
git clone https://github.com/Int3facechain/bridge.git int3face-bridge
```

Then, check out the last released version. Currently, it's `v0.0.7`.

```bash
cd int3face-bridge
git checkout v0.0.7
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
int3faced init <your_moniker> --chain-id=int3-test-1
```

### Download genesis
Download the `genesis.json` file and place it into the Int3face configuration directory (`~/.int3faced/config` by default).
```shell
curl https://github.com/Int3facechain/networks/blob/main/int3-test-1/genesis.json > $HOME/.osmosisd/config/genesis.json
```

### Download app config
Download the `config.toml` file and place it into the Int3face configuration directory (`~/.int3faced/config` by default).
```shell
curl https://github.com/Int3facechain/networks/blob/main/int3-test-1/config.toml > $HOME/.osmosisd/config/genesis.json
```
You can modify the config if it's needed, but make sure to keep all the default ports and persistent peer addresses.  

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
  --amount=1000000uint3 \
  --chain-id="int3-test-1" \
  --moniker="int3face-node-1" \
  --website="https://int3face.io/" \
  --details="Int3face enjoyer" \
  --commission-rate="0.1" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --pubkey='{"@type":"/cosmos.crypto.ed25519.PubKey","key":"w/YfkzNivDZ34y+mbK3/j3WWgYao18tBLf4Ypm2okCU="}'
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

StandardOutput=file:$HOME/.int3faced/logs/int3faced.log
StandardError=file:$HOME/.int3faced/logs/int3faced-error.log
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
git clone https://github.com/Int3facechain/observer.git int3face-int3faced
```

Then, check out the last released version. Currently, it's `v0.0.1`.

```bash
cd int3face-int3faced
git checkout v0.0.1
```

At the top-level directory of the project execute the following command, which will build and install the `int3obsd` binary to `$GOPATH/bin`.

Build the application.
```bash
make install
```
The command above builds and installs the `int3obsd` binary to `$GOPATH/bin`. 

### Init the observer

After that, `int3obsd` can be used to initialize the configuration.
```bash
int3obsd init
```
This creates the observer configuration in the Int3face home directory (`~/.int3faced` by default) with the following folders:
```text
observer
└── default
    ├── node_key
    ├── node_key.pub
    ├── observer.toml
    ├── pool_key.pub
    └── pre_params.hex
```

The `default` folder stores the current observer profile; refer to [Profiles](#profiles) for details. The profile folder contents:
1. `node_key` is the node's private key
2. `node_key.pub` is the node's public key
3. `observer.toml` is the observer config file
4. `pool_key.pub` is the current public key of the committee
5. `pre_params.hex` is the hexed pre-parameters used for the key generation

To launch the observer, all files above must be properly set. Please contact Int3face team to get all the required parameters.

### Start the observer

Start the observer using your validator's account.
```bash
int3obsd start --from <key_name>
```

You will need some way to keep the `int3obsd start` process always running. If you're on linux, you can do this by creating a service.

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

StandardOutput=file:$HOME/.int3faced/observer/default/logs/int3obsd.log
StandardError=file:$HOME/.int3faced/observer/default/logs/int3obsd-error.log
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
