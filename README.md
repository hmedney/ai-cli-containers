# Claude Code wrapper

Convenience script to run Claude Code in a Docker container that only gives Claude Code access to the current directory. Intent is to ensure Claude Code is unable to access host resources outside the current directory.

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
sudo ln -s $PWD/claude-container /usr/local/bin/claude-container
```

Start Claude Code

```sh
cd dir_to_use_claude_code_in

# starts Claude Code in a container that can only access the current directory
claude-container
```
