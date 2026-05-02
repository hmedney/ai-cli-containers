# AI CLI Sandbox

Launch AI CLI tools like claude code and opencode in containers with restricted file system and network access. Tools have no network access except to a http proxy service. This ensures any http requests are logged and can be limited to specified hosts.

## Requirements

- [Docker Desktop](https://docs.docker.com/desktop/) or alternative that provides a working Docker cli, e.g. [podman](https://podman.io/).

Test installation:

```sh
docker run hello-world
```

## Usage

One-time setup

```sh
cd local_clone_of_this_repo
ln -s $PWD/claude ~/bin
```

Run `claude` normally. When launched, it will only have access to the current dir.
