user=$1
zshpath=/home/$user/.zshrc
hostsPath=/etc/hosts


printer() {
    echo "\033[1;34m[Cyrilax Config]: \033[0m$1"
}

# First argument for alias name
# Second argument for alias meaning
addedAlias() {
    echo "\033[1;34m[Cyrilax Config]: \033[0;32mAdded alias \033[0;31m$1\033[0m => $2"
}

installAll() {
    for package in "wget" "git" "zsh" "curl" "cowsay"; do
        status=$(dpkg -s $package | grep Status)
        if [ "$status" = "Status: install ok installed" ]; then
            printer "$package already installed."
        else
            apt install $package
            printer "Installed $package."
        fi
    done
    printer "Downloading oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    printer "Installed oh-my-zsh."
}

zshChecker() {
    if !(grep -Fq "$1" $zshpath) ;
    then
        exit 0
    else    
        exit 1
    fi
}

zshAdd() {
    echo "alias $1=\"$2\"" >> $zshpath
    addedAlias "$1" "$2"
}

hostsConfig() {
    if !(grep -Fq "dcserver" "/etc/hosts") ;
        then
            echo "81.67.11.75 dcserver" >> /etc/hosts
            echo "\033[1;34m[Cyrilax Config]: \033[0;32mAdded host \033[0;31mdcserver\033[0m => 81.67.11.75"
    fi      
}

zshConfig() {
    majCommand="sudo apt-get update && sudo apt-get upgrade && sudo apt autoremove"
    adbPath="/home/$user/Android/Sdk/platform-tools/adb"
    dogconCommand="ssh dcserver -p 324"
    if (zshChecker "alias maj") ;
        then
            zshAdd "maj" "$majCommand"
    fi
    if (zshChecker "export ADB") ;
        then
            echo "export ADB=\"$adbPath\"" >> $zshpath
            echo "\033[1;34m[Cyrilax Config]: \033[0;32mExported variable \033[0;31mADB\033[0m => $adbPath"
    fi
    if (zshChecker "alias dogcon") ;
        then
            zshAdd "dogcon" "$dogconCommand"
    fi
    # if (grep -Fq "")
}


if [ $(whoami) != root ]
    then
        echo "You need to run this script as root."
        exit 1 ;
fi

printer "Welcome $user !"

printer "Starting installation of necessary packages.."

installAll

printer "All packages installed."

printer "Starting configuration of hosts file in /etc/hosts"

hostsConfig

printer "Hosts have been set."

printer "Starting configuration of .zshrc file in $zshpath"

zshConfig

printer "Configuration complete."

sed -i '11d' $zshpath

sed -i '11iZSH_THEME=\"fino\"' $zshpath

echo "ZSH_THEME=\"fino\"" >> $zshpath