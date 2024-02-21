# Colima k8s nix setup

Reproducible environment for Colima and k8s.

Sofar only tested on mac. It should work on linux and windows (on Windows Subsystem for Linux, aka WSL) as well (if not feel free to open a PR).

## Table of contents

- [Download and install `nix`](#download-and-install-nix)
- [Usage](#usage)
  - [How to use this guide](#how-to-read-this-guide)
  - [Commands](#commands)
  - [Garbage collection commands](#garbage-collection-commands)
  - [Important](#important)
- [About `nix`](#about-nix)
  - [What's `nix`?](#whats-nix)
  - [What were you sayng about isolation?](#what-were-you-saying-about-isolation)
- [Container tools: `docker`, `containerd` and `nerdctl`](#container-tools-docker-containerd-and-nerdctl)
- [Advanced usage (optional)](#advanced-usage-optional)
  - [`Lorri` + `direnv`](#lorri--direnv)
  - [Environment isolation](#environment-isolation)
    - [Run with `--pure`](#run-with---pure)
    - [Using a `virtual machine`](#using-a-virtual-machine)
    - [Installing an OS inside the `nix-shell`](#installing-an-os-inside-the-shell)
    - [Nix user profiles](#nix-user-profiles)
- [Future endeavours](#future-endeavours)

## Download and install `nix`

Download and install the [`nix` package manager](https://nixos.org/download).

## Usage

Before running the commands below make sure you wiped out all your global dependencies. 

Here is an example in case you used `homebrew`:

```console
my-computer:~$ which kubectl
/opt/homebrew/bin/kubernetes-cli
my-computer:~$ brew uninstall kubectl
Uninstalling /opt/homebrew/Cellar/kubernetes-cli/<version>...
my-computer:~$ which colima
/opt/homebrew/bin/colima
my-computer:~$ brew uninstall colima
Uninstalling /opt/homebrew/Cellar/colima/<version>...
```

If you also have `docker` installed globally on your machine, you should also uninstall it if you want a clean slate, because in the `shell.nix` file there is an `alias` for `docker` that could mess up your configuration.

Make sure that `colima` config files are deleted as well (they are usually in the `~` directory under `~/.config/colima`).
You can proceed without deleting these dependencies, but global configuration could clash with the local one and some of the commands may not work properly.

There is [a way to make this work in any case without uninstalling your global packages](#run-with---pure), but it's less simple.

### How to read this guide

There are commands that you will need to run inside your `shell`, these are prefixed by `my-computer:~/colima-k8s-nix$` assuming you clone this repo in your home directory `~` or `/Users/<your-username>` on Mac and `/users/<your-username>` on Linux.

The commands that you need to run in the `nix-shell` are prefixed with `[nix-shell:~/colima-k8s-nix]$` instead.

### Commands

Start a `nix-shell` with colima and k8s:

```console
my-computer:~/colima-k8s-nix$ nix-shell
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

`Nix` is really powerful, but in its raw state it generates a lot of garbage. There are [some ways to handle this gracefully](#lorri--direnv), but for now just run commands that handle garbage collection.

```console
my-computer:~/colima-k8s-nix$ nix-env --delete-generations old
my-computer:~/colima-k8s-nix$ nix-store --gc
my-computer:~/colima-k8s-nix$ nix-collect-garbage -d
```

You can also run `nix-collect-garbage` if you're not sure which packages you should get rid of.

More on `nix` garbage collection can be found [here](https://nixos.org/manual/nix/stable/package-management/garbage-collection).

### Important

Before leaving the `nix-shell` make sure that you stopped and deleted all the instances of `colima`. 

In fact although the local dependencies of the shell are separated from the one on your local machine (you can find more about this topic here [here](#what-were-you-saying-about-isolation)) you still share your file system, user groups etc. with the `nix-shell`. In this way the shell is the closest environment to your local without messing up your installed dependencies. This approach has advantages and disadvantages.

:exclamation::exclamation:**Please make sure to run the commands to delete colima instances and the garbage collection commands after you're done developing**.

## About `nix`

### What's `nix`?

[`Nix`](https://nixos.org/) is a cross-platform package manager. It uses the [`nix` programming language](https://nixos.org/manual/nix/stable/language/index.html). `Nix` and `NixOs` are often used in the same context, but while the first is a package manager, the latter is a linux distribution based on `nix`.

The `nix` ecosystem comes with a lot of tools. The `nix-shell` is one of these. Under the hood it uses the `nix` packages, aka `nixpkgs`, which are packages that can be found in this [repository](https://search.nixos.org/packages).  

One of the advantages of using the `nix` ecosystem is the capacity to make reproducible, declarative and reliable systems. One of the disadvantages is that getting to know this ecosystem can be very overwhelming and therefore it has a steep learning curve when compared to other build tools.

### What were you saying about isolation?

So far we know that we can tap in this "magic" shell that has everything that we need without the hassle. 

But *what* is this exactly? Is this a *container*? Is this a *virtual machine*? Let's ask our shell to give us some information about our operating system and platform:

```console
my-computer:~/colima-k8s-nix$ uname -a
```

And now let's ask the `nix-shell`:

```console
[nix-shell:~/colima-k8s-nix]$ uname -a
```

You will notice that the answer is exactly the same. This is certainly not what we would obtain if we would run the same command in a `docker` container or in a `virtual machine`. So our `nix-shell` *shares ressources* with our machine.

What does this mean for us? One of the consequences of this is that when we run commands on **this** `nix-shell` (which is configured as in the `shell.nix` file), it's as if we would install those dependencies on our machine with `homebrew` for example. This also means that if we create a file from the `nix-shell`, we will be able to find it if we jump back to our normal shell:

```console
[nix-shell:~/colima-k8s-nix]$ touch test.txt
```

```console
my-computer:~/colima-k8s-nix$ ls
LICENSE   README.md     shell.nix      test.txt  
```

And the same goes if we first create a file through our regular shell and we want to read it from the `nix-shell`. So the environment[^1] that we have in the `nix-shell` is closer to our **real** shell. This is why we have to handle the memory responsibly and use garbage collection commands. The memory that nix uses to download and install packages is the physical memory of our machine, not the virtualized one (like in the case of `containers` and `virtual machines`).

This also means that if we exit the shell without stopping and deleting the `colima` instance that we started, it will continue to run even when we exit the `nix-shell` and even if we don't have `colima` installed globally.

## Container tools: `docker`, `containerd` and `nerdctl`

You might have noticed that inside the `nix-shell` we've created the `colima` instance with the flag `-r containerd`. In fact if you try to run the same command without the flag you will get this error:

```console
INFO[0000] starting colima
INFO[0000] runtime: docker+k3s
FATA[0000] dependency check failed for docker: docker not found, run 'brew install docker' to install
```

Why is that? In the `shell.nix` file we only have `colima` and `kubernetes` as dependencies. `colima` already ships with `containerd`, which is the same `container runtime` that [docker uses under the hood](https://www.docker.com/blog/what-is-containerd-runtime/). So since we are already using `colima` we don't need to download `docker` for the runtime.

What about the `docker-cli`? `colima` also ships with a [docker-compatible cli to interact with `containerd` called `nerdctl`](https://github.com/containerd/nerdctl). We can execute the same `docker` cli commands like:

```console
[nix-shell:~/colima-k8s-nix]$ colima nerdctl pull nginx
```

For brevity and "developer experience" I created a local alias in `shell.nix` for `colima nerdctl` which is called `docker`:

```console
[nix-shell:~/colima-k8s-nix]$ type docker
docker is aliased to `colima nerdctl'
```

:exclamation::exclamation: **Please note that this `alias` could clash with your global configuration if you have `docker` installed globally on your machine.**

## Advanced usage (optional)

This is by no means an exaustive list of how you can customize your builds, deployments and development environments with `nix`, but just some examples.

### `lorri` + `direnv`

`lorri` is a `nix-shell` replacement for project development. Once you've [downloaded and installed it](https://github.com/nix-community/lorri?tab=readme-ov-file#setup-on-other-platforms) you can initialize your project like this:

```console
my-computer:~/colima-k8s-nix$ lorri init
```

This command will also create an `.envrc` file in which you can configure your shell. Then you can run:

```console
my-computer:~/colima-k8s-nix$ lorri deamon
```

`lorri`'s deamon gives you information about your shell, takes care of the garbage collection for you and "watches" your shell.nix files for changes, so you don't need to reload the shell if you add a dependency. Neat!

Moreover `lorri` works together with `direnv`.

One downside of using `nix-shell` is that you can only use `bash` inside of it. Instead when using `lorri` in the newly created `.envrc` file you can define other shells like `zsh` or `fish`, thanks to `lorri`'s integration with `direnv`.

### Environment isolation

#### Run with `--pure`

When you run the `nix-shell`, it inherits your global configuration by default. If you don't want the already installed packages to affect your development and productivity, you can run:

```console
my-computer:~/colima-k8s-nix$ nix-shell --pure
```

The `pure` flag gives you a clean slate. But in this case the `nix-shell` will only have installed the packages that are specified in `shell.nix`. So for example in a `nix-shell --pure`:

```console
[nix-shell:~/colima-k8s-nix]$ ls 
bash: ls: command not found
```

So if you will need `ls` or other commands that come with your Unix operating system, you will have to specify them in the `shell.nix` file together with the other packages:

```nix
[...]

  buildInputs = with pkgs.buildPackages; [
    ls
    colima
    kubectl
  ];

[...]
```

#### Using a `virtual machine`

You can run a [`virtual machine` (e.g. `lima`)](https://lima-vm.io/) from inside a `nix-shell`, exactly as you would do with a regular shell.

In this case `lima` will provide with the level of isolation that `nix-shell` lacks when we don't pass the `pure` flag. In this case the control is relinquished to the `virtual machine`, so e.g. `lima` can't write by default in the `~` folder, but provides an isolated folder in which it has both reading and writing rights. 

#### Installing an OS inside the shell

Although this is a different approach with respect to using an already existing `virtual machine`, we can achieve similar results in terms of isolation and to which we can do inside the shell (for example combined with the `pure` flag).

It goes without saying, that you can download the `NixOs` linux distro within your `nix-shell`. But you can install other operating systems as well, like you would do in a `container` or `virtual machine`.

So as you can see, this is the power of `nix`, we started from a simple package management problem and incrementally we are building a `virual machine` in a declarative way. Simply amazing!

This is an example of how `nix-shell` allows you to create **ephemeral environments**. [Check this video if you want to know more](https://www.youtube.com/watch?v=0ulldVwZiKA).

#### `nix` user profiles

Let's put aside the level of isolation that a `virtual machine` guarantees for a moment.

Another possibility to partially isolate in `nix` is using user profiles. If you have multiple users in your machine you can switch between them and also give root priviledges to any user for whatever specific action. In this case, without additional isolation though, you can affect existing users on your machine.

## Future endeavours

I might add other examples in this repo with advanced usage options.

[^1]: I'm using this term loosely here, not necessarily related to `nix-env` which is a concept and tool of its own.
