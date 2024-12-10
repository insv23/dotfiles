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

- Create a directory, connect it to the remote repository, and then pull.

  ```shell
  mkdir .dotfiles
  cd .dotfiles
  git config --global init.defaultBranch main
  git init
  git remote add origin https://github.com/insv23/dotfiles.git
  git pull origin main
  ```

  ```shell
  git branch --set-upstream-to=origin/main main
  ```

- Run `./install`  
   If some files or directory already exist, manually delete them before running `./install` again. For example,

  ```shell
  rm ~/.profile && rm ~/.bashrc && rm ~/.gitconfig && ./install
  ```

- Push commits in a new machine to the remote repository

  ```shell
  git push --set-upstream origin main
  ```

  Have some boring 2FA works here.
