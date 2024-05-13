# Integration instructions

## Prerequisites

This project requires Go version 1.22 or later. Install Go by following the instructions on the official [Go installation guide](https://go.dev/doc/install).

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

### Initialize node

Use `int3faced` to initialize your node (replace the `NODE_NAME` with a name of your choosing):

```bash
int3faced init NODE_NAME --chain-id=osmo-test-5
```

_TODO: Do we need to update the persistent peer list in the chain config? How do peers discover each other?_

### Download chain data

_TODO: Where is the chain data located? Who should upload it?_

### Download genesis file

_TODO: Do we need to upload the genesis file?_

## Observer node

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
The command above builds and installs the `int3obsd` binary to `$GOPATH/bin`. After that, `int3obsd` can be used to initialize the configuration.
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

To launch the observer, all files above must be properly set. Please contact Int3face team for getting all required parameters.
