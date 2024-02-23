# Automatic environments

Table of contents

- [Install `direnv`](#install-direnv)
- [Setup](#setup)
  - [bash](#bash)
  - [zsh](#zsh)
  - [Other shells](#other-shells)
- [Granting permissions to `direnv`](#grant-permission-to-direnv)  
- [Usage](#usage)

## Install `direnv`

Install `direnv` with one of the methods suggested [here](https://github.com/nix-community/nix-direnv).

## Setup

To activate automatic environments you have to setup the hook.

### bash

Add the following line at the end of the `~/.bashrc` file:

```console
eval "$(direnv hook bash)"
```

### ZSH

Add the following line at the end of the `~/.zshrc` file:

```console
eval "$(direnv hook bash)"
```

### Other shells

Other shells setup can be found [here](https://direnv.net/docs/hook.html)

## Grant permission to `direnv`

```console
my-computer:~/colima-k8s-nix$ direnv allow
```

## Usage

With `direnv` you don't need to start a `nix-shell` every time. You can work using your regular shell:

```console
my-computer:~/colima-k8s-nix/automatic-environments$ colima --help
Colima provides container runtimes on macOS with minimal setup.

Usage:
  colima [command]

Available Commands:
  completion  Generate completion script
  delete      delete and teardown Colima
  help        Help about any command
  kubernetes  manage Kubernetes cluster
  list        list instances
  nerdctl     run nerdctl (requires containerd runtime)
  prune       prune cached downloaded assets
  restart     restart Colima
  ssh         SSH into the VM
  ssh-config  show SSH connection config
  start       start Colima
  status      show the status of Colima
  stop        stop Colima
  template    edit the template for default configurations
  version     print the version of Colima

Flags:
  -h, --help             help for colima
  -p, --profile string   profile name, for multiple instances (default "default")
  -v, --verbose          enable verbose log
      --version          version for colima
      --very-verbose     enable more verbose log

Use "colima [command] --help" for more information about a command.
```
