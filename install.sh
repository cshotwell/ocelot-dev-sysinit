#!/usr/bin/env bash

if ! [[ -d "/Applications/Xcode.app" ]]
then
  echo -e "\nIt looks like you don't have Xcode installed. You need Xcode 4.3 or higher with the Command Line Tools installed to be able to continue"
  exit
else
  echo -e "\nYou have `xcodebuild -version` installed"
fi

result=`which gcc`

if [[ -z "$result" ]]
then
  echo -e "\nIt looks like the Command Line Tools aren't installed. If you have Xcode 4.3 or higher installed, launch Xcode, open the preferences, click on Downloads, and be sure to install the Command Line Tools!\n\nAfter you have installed the Command Line Tools, rerun this script."
  exit
fi

result=`which brew 2>&1`

if [[ -z "$result" ]]
then
  echo -e "\nHomeBrew is not installed"
  echo "Installing HomeBrew"
  ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
  echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.bashrc
  source ~/.bashrc
  brew tap homebrew/dupes
else
  echo -e "\nHomeBrew is already installed: `echo $result`"
  echo "Upgrading HomeBrew to the latest build"
  brew update
  brew tap homebrew/dupes
fi

result=`brew list`

if ! [[ $result =~ ack ]]
then
  echo -e "\nInstalling Ack, this will help with Vim later"
  brew install ack
fi

othergit=`which git`

if ! [[ $result =~ git || -z "$othergit" ]]
then
  echo -e "\nInstalling git, you'll need this for source control"
  brew install git

  cat >> ~/.gitconfig <<EOL
[color]
  diff = auto
  status = auto
  branch = auto
  interactive = auto
  ui = auto
[gc]
  auto = 1
[merge]
  summary = true
[alias]
  co = checkout
  ci = commit -v
  st = status
  cp = cherry-pick -x
  rb = rebase
  pr = pull --rebase
  br = branch
  b = branch -v
  r = remote -v
  t = tag -l
  put = push origin HEAD
  unstage = reset HEAD
  uncommit = reset --soft HEAD^
  recommit = commit -C head --amend
  d = diff
  c = commit -v
  s = status
  dc = diff --cached
  pr = pull --rebase
  ar = add -A
EOL

  echo " "
  read -p "What is your first & last name to be used in Git commits (ie. John Doe) : "
  echo
  git config --global user.name "$REPLY"

  echo " "
  read -p "What is your email to be used in Git commits (ie. john.doe@leandog.com) : "
  echo
  git config --global user.email "$REPLY"
fi

if ! [[ $result =~ apple-gcc42 ]]
then
  echo -e "\nInstalling Apple's older GCC 4.2 binaries from HomeBrew to be able to build Ruby prior to 1.9.3 and most gems"
  brew install apple-gcc42
  echo -e "\nSymlinking GCC in"
  #sudo ln -s /usr/local/bin/gcc-4.2 /usr/bin/gcc-4.2
fi

if ! [[ $result =~ macvim ]]; then
  echo -e "\nInstalling MacVim since it is much newer than the Vim installed in OS X"
  brew install macvim --override-system-vim

  source ~/.bashrc
  echo -e "\nInstall Pathogen plugin for Vim"
  mkdir -p ~/.vim/autoload ~/.vim/bundle
  curl -so ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

  echo -e "\nInstalling a script to get some useful Vim plugins"
  curl -so ~/.vim/update_bundles https://raw.github.com/leandog/ocelot-dev-sysinit/master/update_bundles
  chmod 755 ~/.vim/update_bundles
  ~/.vim/update_bundles

  if ! [[ -f ~/.vimrc ]]
  then
    echo -e "\nInstalling a default .vimrc"
    curl -so ~/.vimrc https://raw.github.com/leandog/ocelot-dev-sysinit/master/.vimrc
  else
    echo -e "\nYou appear to already have a .vimrc, here's what we would've put in there...\n"
    curl https://raw.github.com/leandog/ocelot-dev-sysinit/master/.vimrc
  fi
fi

result=`which rvm`

if [[ -z "$result" ]]
then
  echo -e "\nRVM Not installed"
  echo "Installing RVM"
  touch ~/.bashrc
  curl -L https://get.rvm.io | bash -s stable
  curl -so ~/.rvmsh https://raw.github.com/gist/898797/ead7ee759f8a1445db781b5b15bda49b418311f4//etc/profile.d/rvm.sh
  cat >> ~/.bashrc <<EOL
#export CC=/usr/local/bin/gcc-4.2
source ~/.rvmsh
EOL

  echo -e "\nInstalling a default .gemrc"
  echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
  echo -e "\nInstalling a default .rvmrc"
  cat > ~/.rvmrc <<EOL
rvm_ps1=1
rvm_path="${HOME}/.rvm"
rvm_pretty_print_flag=1
rvm_gemset_create_on_use_flag=1
EOL

  source ~/.bashrc
  rvm reload
else
  echo -e "\nRVM installed: `echo $result`"
  echo "Upgrading RVM to the latest build"
  rvm get head
  rvm reload
fi

if ! [[ -f ~/.bash_profile ]]
then

  echo -e "\nLooks like you don't have a .bash_profile, let's make one!"
  touch ~/.bash_profile

  cat > ~/.bash_profile <<EOL
if [ -f ~/.bashrc ] && [ "${SHELL##*/}" == "bash" ]
then
  . ~/.bashrc
fi
EOL

fi

