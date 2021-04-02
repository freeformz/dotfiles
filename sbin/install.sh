#!/usr/bin/env zsh

set -e

typeset -A requirements
requirements=()
need=()

[[ $(hostname) =~ "abc" ]] && situation="work" || situation="home"

if [[ $(uname -s) =~ "Darwin" ]]; then
  SED=gsed
  requirements+=(gpg "brew install gnupg")
  requirements+=(git-lfs "brew install git-lfs")
  requirements+=(git-codereview "GO111MODULE=off go get -u golang.org/x/review/git-codereview")
  requirements+=(jq "brew install jq")
  #requirements+=(keybase "https://keybase.io")
  requirements+=(code "F1 -> Install code command in PATH")
  requirements+=(docker "https://docker.com")
  requirements+=(gsed "brew install gnu-sed")
  requirements+=(/usr/local/bin/brew "https://brew.sh")
  requirements+=(/usr/local/bin/git "brew install git")
fi

if [[ $(uname -s) == "Linux" ]]; then
  SED=sed
  requirements+=(gpg "apt-get install gpg")
  requirements+=(git-lfs "apt-get install git-lfs")
  #requirements+=(git-codereview "GO111MODULE=off go get -u golang.org/x/review/git-codereview")
  requirements+=(jq "apt-get install jq")
  requirements+=(keybase "https://keybase.io/docs/the_app/install_linux")
  #requirements+=(code "F1 -> Install code command in PATH")
  requirements+=(docker "https://docker.com")
  requirements+=(sed "apt-get install sed")
  requirements+=(git "apt-get install git")
fi

#if [[ "${situation}" == "work" ]]; then
#  requirements+=(lpass "brew install lastpass-cli")
#fi

for r in ${(k)requirements}; do
  if ! PATH=/usr/local/bin:$PATH type ${r} >>&/dev/null; then
    need+="${requirements[$r]}"
  fi
done

if [[ $#need -gt 0 ]]; then
  echo "Missing requirements, to resolve run:"
  for i in ${need}; do
    echo "\t${i}"
  done
  exit 1
fi


typeset -A files
files=(
  zshrc ~/.zshrc
  gitconfig ~/.gitconfig
)

base=$(git rev-parse --show-toplevel)
source="${base}/source"


case ${situation} in
  work)
    files[zshrc.work.gpg]="$HOME/.zshrc.work"
    export EMAIL="emuller@salesforce.com"
    export KEY="FC5833DB021899A5"
  ;;
  home)
    export EMAIL="freeformz@gmail.com"
    export KEY="4425D7E25D8A8486"
  ;;
  *)
    echo "unknown situation"
    exit 1
  ;;
esac


if  ! gpg -k ${KEY} &> /dev/null; then
  echo "Missing key in local keychain. Install keybase, then run:"
  echo "keybase pgp export -q ${KEY} | gpg --import"
  echo "keybase pgp export -q ${KEY} --secret | gpg --import --allow-secret-key-import"
  exit 1
fi

for f in ${(k)files}; do
  local tgt=${files[$f]}
  local tmp=$(mktemp)
  if [[ "${f:t:e}" == "gpg" ]]; then
    echo "processing gpg encrypted file: ${f}"
    gpg --yes --output "${tmp}" --decrypt "${source}/$f"
  else
    cp -f "${source}/$f" ${tmp}
  fi
  $SED -i -e "s:__HOME__:${HOME}:g" ${tmp}
  $SED -i -e "s:__EMAIL__:${EMAIL}:g" ${tmp}
  $SED -i -e "s:__KEY__:${KEY}:g" ${tmp}

  # ensure the file exists or diff complains
  if [[ ! -e ${tgt} ]]; then
    touch ${tgt}
  fi

  # diff/patch to get some interactivity in case there is a conflict
  diff -p ${tgt} ${tmp} | patch ${tgt}
done