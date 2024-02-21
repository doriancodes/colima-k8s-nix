# Colima k8s nix setup
Reproducible environment for Colima and k8s. Sofar only tested on mac. It should work on linux and windows (on Windows Subsystem for Linux, aka WSL) as well (if not feel free to open a PR).

## Table of contents
- [Download and install `nix`](#download-and-install-nix)
- [Usage](#usage)
  - [How to use this guide](#how-to-read-this-guide)
  - [Commands](#commands)
  - [Garbage collection commands](#garbage-collection-commands)
  - [Important](#important)
- [Some words on `nix`](#some-words-on-nix)
  - [What's `nix`?](#whats-nix)
  - [What happened exactly?](#what-happened-exactly)
  - [What were you sayng about isolation?](#what-were-you-saying-about-isolation)
- [Some words about `docker` and containers in general](#some-words-on-docker-and-containers-in-general)
- [Advanced usage (optional)](#advanced-usage-optional)
  - [`Lorri` + `direnv`](#lorri--direnv)
  - [Environment isolation](#environment-isolation)
    - [Run with `--pure`](#run-with---pure)
    - [Using a vm](#using-a-vm)
    - [Nix user profiles](#nix-user-profiles)
- [Future endeavours](#future-endeavours)

## Download and install `nix`

Download and install the [`nix` package manager](https://nixos.org/download).

## Usage
Before running the commands below make sure you wiped out all your global dependencies. 

Here is an example in case you used `homebrew`:
```console
&#8203;~$ which kubectl
/opt/homebrew/bin/kubernetes-cli
&#8203;~$ brew uninstall kubectl
Uninstalling /opt/homebrew/Cellar/kubernetes-cli/<version>...
:~$ which colima
/opt/homebrew/bin/colima
:~$ brew uninstall colima
Uninstalling /opt/homebrew/Cellar/colima/<version>...
```
Make sure that `colima` config files are deleted as well (they are usually in the `~` directory under `~/.config/colima`).
You can proceed without deleting these dependencies, but global configuration could clash with the local one and some of the commands may not work properly.

### How to read this guide
There are commands that you will need to run inside your `shell`, these are prefixed by `~/colima-k8s-nix$ ` assuming you clone this repo in your home directory `~` or `/Users/<your-username>` on Mac and Linux.

The commands that you need to run in the `nix-shell` are prefixed with `[nix-shell:~/colima-k8s-nix]$` instead.

### Commands

Start a `nix-shell` with colima and k8s:
```console
~/colima-k8s-nix$: nix-shell
```
Inside the shell type:
```console
[nix-shell:~/colima-k8s-nix]$ colima start --cpu 4 --memory 8 --network-address --kubernetes -r containerd
```
Pulling docker images:
```console
[nix-shell:~/colima-k8s-nix]$ docker pull nginx
[nix-shell:~/colima-k8s-nix]$ docker pull openjdk:alpine
[nix-shell:~/colima-k8s-nix]$ docker pull mongo
```
Verifying that colima is in kubernetes mode:
```console
[nix-shell:~/colima-k8s-nix]$ kubectl run -i --tty busybox --image=busybox -- sh
```
Exit from k8s mode: `ctrl + d`.

Stop colima runtime to free CPU and memory:
```console
[nix-shell:~/colima-k8s-nix]$ colima stop
```
Delete and tear down colima instances:
```console
[nix-shell:~/colima-k8s-nix]$ colima delete default #colima delete <name-of-the-instance>
```
Exit from `nix-shell` by typing:
```console
[nix-shell:~/colima-k8s-nix]$ exit
```

### Garbage collection commands

`Nix` is really powerful, but in its raw state it generates a lot of garbage. There are some ways to handle this gracefully, but for now just run commands that handle garbage collection.
```console
~/colima-k8s-nix$: nix-env --delete-generations old
~/colima-k8s-nix$: nix-store --gc
~/colima-k8s-nix$: nix-collect-garbage -d
```
More on `nix` garbage collection can be found [here](https://nixos.org/manual/nix/stable/package-management/garbage-collection).

### Important

Before leaving the `nix-shell` make sure that you stopped and deleted all the instances of `colima`. 

In fact although the local dependencies of the shell are separated from the one on your local machine (not entirely, I'll explain later) you still share your file system, user groups etc. with the `nix-shell`. In this way the shell is the closest environment to your local without messing up your installed dependencies. This approach has advantages and disadvantages (more on that later).

:exclamation::exclamation:<u>**Please make sure to run the commands to delete colima instances and the garbage collection commands after you're done developing**</u>.

## Some words on `nix`
### What's `nix`?
### What happened exactly?
### What were you saying about isolation?

## Some words on `docker` and `containers` in general
You might have noticed that inside the `nix-shell` we've created the `colima` instance with the flag `-r containerd`. In fact if you try to run the same command without the flag you will get this error:
```console
TODO add error here
```
Why is that? In the `shell.nix` file we only have `colima` and `kubernetes` as dependencies. `colima` already ships with `containerd`, which is the same container runtime that docker uses (add link reference). So since we are already using `colima` we don't need to download `docker` for the runtime. 
What about the `docker-cli`? `colima` also ships with a docker-compatible cli to interact with `containerd` called [`nerdctl`](https://github.com/containerd/nerdctl). We can execute the same `docker` cli commands like:
```console
[nix-shell:~/colima-k8s-nix]$ colima nerdctl pull nginx
```
For brevity and "developer experience" I created a local alias in `shell.nix` for `colima nerdctl` which is called `docker`. 

## Advanced usage (optional)
### `Lorri` + `direnv`
Lorri -> garbage collection + reload on change
direnv zsh or fish instead of bash
### Environment isolation
#### run with `--pure`
#### using a vm 
e.g. lima
#### installing an os instide the shell
#### nix user profiles

## Future endeavours
I might add other examples in this repo with advance usage options.