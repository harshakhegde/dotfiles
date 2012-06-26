source ~/dotfiles/ttycolors/zenburn.sh
setopt AUTOCD
setopt CD_ABLE_VARS
setopt PUSHD_IGNORE_DUPS AUTOPUSHD
set -o vi
if [[ $OS = Windows* ]]; then
    progfiles="`/usr/bin/cygpath -au 'c:\Program Files (x86)'`"
fi

export PATH="/usr/bin:${PATH}"

# http://superuser.com/questions/362227/how-to-change-the-title-of-the-mintty-window
# Change title of MinTTY to current dir
function settitle() {
    echo -ne "\033]2;"$1"\007"
}
function chpwd() {
    settitle $(cygpath -m `pwd`)
}

expl() {
	if [[ -z "$1" ]]; then
		explorer `cygpath -aw "."`
	else
		explorer `cygpath -aw "$1"`
	fi
}

spdf() {
    if [[ -z "$1" ]];then
        echo "Usage: spdf <pdfPath>"
    else
        pdfPath=`cygpath -aw  "$1"`
        "$progfiles/SumatraPDF/SumatraPDF.exe" "$pdfPath" 
    fi
}

wdiff() {
    # C:\Program Files (x86)\WinMerge
    if [[ $# -lt 2 ]]; then
        echo "Usage: wdiff <file1> <file2>"
    else
        f1=`cygpath -aw  "$1"`
        f2=`cygpath -aw  "$2"`
        "$progfiles/WinMerge/WinMergeU.exe" "$f1" "$f2"
    fi
}

scite() {
    if [[ -z "$1" ]];then
        echo "Usage: scite <filePath>"
    else
        fpath=`cygpath -aw "$1"`
        "$progfiles/SciTE/SciTE.exe" "$fpath"
    fi
}

function proxyset() {
    if [[ $LOGONSERVER == *BLR* ]]; then
        export http_proxy="http://proxy.blrl.sap.corp:8080"
        export https_proxy="http://proxy.blrl.sap.corp:8080"
    elif [[ $LOGONSERVER == *WDF* ]]; then
        export http_proxy="http://proxy.wdf.sap.corp:8080"
        export https_proxy="http://proxy.wdf.sap.corp:8080"
    fi
    if [[ ! -z $http_proxy ]]; then
        echo "Proxy set to $http_proxy"
    fi
}

function proxyclear() {
    unset http_proxy
    unset https_proxy
}


if [[ $USERDOMAIN == SAP_ALL ]]; then
    proxyset
fi

export EDITOR='vim'
source ~/dotfiles/histenv
function gitenv-sap() {
    source ~/dotfiles/gitenv-sap
}
function gitenv-hub() {
   source ~/dotfiles/gitenv-hub
}

# Mounts
if [[ $OS = Windows* ]]; then
    if [[ -d /cygdrive/c ]]; then
        mount c: /c 2> /dev/null
    fi
    if [[ -d /cygdrive/d ]]; then
        mount d: /d 2> /dev/null
    fi
fi

#bindkeys
bindkey ' ' magic-space

export SHELL='zsh'
export PS1='%~$ '

# Autoloads
# http://www.refining-linux.org/archives/36/ZSH-Gem-1-Programmable-file-renaming/
autoload -U zmv

if [ -f "${HOME}/dotfiles/aliases" ]; then
   source "${HOME}/dotfiles/aliases"
fi

cd ~/dotfiles

#Setup SSH Agent
#http://holdenweb.blogspot.in/2007/12/cygwin-ssh-agent-control.html
export SSH_AUTH_SOCK=/tmp/.ssh-socket

ssh-add -l >/dev/null 2>&1
if [ $? = 2 ]; then
# Exit status 2 means couldn't connect to ssh-agent; start one now
rm -rf /tmp/.ssh-*
ssh-agent -a $SSH_AUTH_SOCK >/tmp/.ssh-script
. /tmp/.ssh-script
echo $SSH_AGENT_PID >/tmp/.ssh-agent-pid
fi


function kill-agent {
pid=`cat /tmp/.ssh-agent-pid`
kill $pid
}


