#!/usr/bin/env zsh

EMAIL_WORK=emuller@fastly.com
KEY_WORK="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDDc/726/BtTHZ6+EBCEOvRo2PRTIYzM3v/e48qj+4R emuller@fastly.com"
EMAIL_HOME=me@freeformz.me
KEY_HOME=""

set -e

typeset -A requirements
requirements=()
need=()

situation="home"
if pgrep crowdstrike >& /dev/null; then
  situation="work"
fi

echo $situation

if [[ $(uname -s) =~ "Darwin" ]]; then
  SED=gsed
  requirements+=(age "brew install age")
  requirements+=(git-lfs "brew install git-lfs")
  requirements+=(git-codereview "GO111MODULE=off go get -u golang.org/x/review/git-codereview")
  requirements+=(jq "brew install jq")
  #requirements+=(keybase "https://keybase.io")
  requirements+=(code "F1 -> Install code command in PATH")
  requirements+=(docker "https://docker.com")
  requirements+=(gsed "brew install gnu-sed")
  requirements+=(minisign "go install aead.dev/minisign/cmd/minisign@latest")
  requirements+=(/usr/local/bin/brew "https://brew.sh")
  requirements+=(/usr/local/bin/git "brew install git")
fi

if [[ $(uname -s) == "Linux" ]]; then
  SED=sed
  requirements+=(age "apt-get install age")
  requirements+=(git-lfs "apt-get install git-lfs")
  #requirements+=(git-codereview "GO111MODULE=off go get -u golang.org/x/review/git-codereview")
  requirements+=(jq "apt-get install jq")
  requirements+=(keybase "https://keybase.io/docs/the_app/install_linux")
  #requirements+=(code "F1 -> Install code command in PATH")
  requirements+=(minisign "go install aead.dev/minisign/cmd/minisign@latest")
  requirements+=(docker "https://docker.com")
  requirements+=(sed "apt-get install sed")
  requirements+=(git "apt-get install git")
fi

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
    files[zshrc.work.age]="$HOME/.zshrc.work"
    export EMAIL=${EMAIL_WORK}
    export KEY=${KEY_WORK}
  ;;
  home)
    export EMAIL=$EMAIL_HOME
  ;;
  *)
    echo "unknown situation"
    exit 1
  ;;
esac

mkdir -p ~/.ssh
mv ~/.ssh/allowed_signers ~/.ssh/allowed_signers.old
echo $EMAIL_WORK $KEY_WORK >> ~/.ssh/allowed_signers
#echo FIXME 4 HOME

#if  ! gpg -k ${KEY} &> /dev/null; then
#  echo "Missing key in local keychain. Install keybase, then run:"
#  echo "keybase pgp export -q ${KEY} | gpg --import"
#  echo "keybase pgp export -q ${KEY} --secret | gpg --import --allow-secret-key-import"
#  exit 1
#fi

for f in ${(k)files}; do
  local tgt=${files[$f]}
  local tmp=$(mktemp)
  if [[ "${f:t:e}" == "age" ]]; then
    echo "processing age encrypted file: ${f}"
    age -d -i ~/.ssh/id_ed25519 "${source}/$f" > "${tmp}"
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