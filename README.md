# How to Use

## First install

Here is my install log: [dotfiles | insv の blog](https://blog.insv.xyz/dotfiles), it may help you get started.

- Init script from [Vaelatern/init-dotfiles: Quickly get your dotfiles up and running](https://github.com/Vaelatern/init-dotfiles)

  ```shell
  curl -fsSLO https://raw.githubusercontent.com/Vaelatern/init-dotfiles/master/init_dotfiles.sh
  chmod +x ./init_dotfiles.sh
  ./init_dotfiles.sh
  ```

- Modify your config files, for example, `~/.vimrc` , and tweak `.install.conf.yaml`

  - Hidden files or directories do **not** require the prefix `.`

    For example, `~/.vim`

    1. `mkdir vim`
    2. Add an entry in the `.install.conf.yaml` file: `~/.vim:`

  - If you are using git submodules, please make sure to add the submodule to the `gitconfig` file.

    ```shell
    git submodule add -f <Github URL> <path>
    git submodule add -f https://github.com/tmux-plugins/tmux-cpu.git tmux/plugins/tmux-cpu
    ```

- Validate that the configuration is correct by running the `.install.conf.yaml` again

- Commit and push to GitHub

## Use on a new machine

- 🚫 [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux) does not yet support ARM Linux.

- ⚠️ Homebrew on Linux cannot be installed as root user.

  So you may need to create a new user before installing Homebrew on Linux:

  ```shell
  NEW_USER_NAME=alex
  sudo useradd -m -s /bin/bash -G users,sudo $NEW_USER_NAME && sudo passwd $NEW_USER_NAME
  ```

- ⛑️ git and zsh are required.

  For example, install git and zsh on Ubuntu:

  ```shell
  sudo apt update && sudo apt install git zsh -y
  ```

- Just clone the repository and run `./install`

  ```shell
  git clone https://github.com/insv23/dotfiles.git .dotfiles && cd .dotfiles
  ```

- Run `./install`  
   If some files or directory already exist, manually delete them before running `./install` again. For example,

  ```shell
  rm -f ~/.profile ~/.bashrc ~/.gitconfig && ./install
  ```

- Push commits in a new machine to the remote repository

  ```shell
  git push --set-upstream origin main
  ```

  Have some boring 2FA works here.
