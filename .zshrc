#### Exports

# Set path envar to homebrew directory at $HOME/.homebrew/, and custom binary folder at $HOME/.binaries
export PATH=$HOME/.binaries:$HOME/.homebrew/bin:$PATH
export FPATH=$HOME/.zsh:$HOME/.homebrew/share/zsh/site-functions:$FPATH

# Enable cli colours
export CLICOLOR=1

# Set hostory options
export HISTSIZE=100000
export SAVEHIST=1000000

#### Options
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_NO_STORE
setopt PROMPT_SUBST

#### Plugins

# Load prompt
autoload -Uz promptinit

# Set prompt theme
promptinit
prompt wego

# Functions
sign ()
{
    # Get available certificates
    number=1
    IFS=$'\n'
    for cert in $(/usr/bin/security find-certificate -a -c Developer | awk -F '=' '/"alis"/ {print $2}' | awk '/\(.*\)/ { print }' | sed 's/"//g')
    do
        cnames+=("${cert}")
        echo "$number) ${cert}"
        let "number += 1"
    done
    unset IFS
    if [[ -z ${cert} ]]
    then
        echo "No certificates available to sign. Exiting..."
        exit 1
    else
        echo "Select a certificate: "
        read cid
        chosenCert=${cnames[${cid}]}
    fi

    # Determine signing target and sign as required
    file=$(basename "${1}")
    if [[ "${1}" =~ .pkg || "${1}" =~ .mpkg ]]
    then
        echo "Signing package..."
        /usr/bin/productsign --sign "${chosenCert}" "${1}" "$(dirname "${1}")/Signed-${file}"
    else
        echo "Signing code..."
        /usr/bin/security cms -S -N "${chosenCert}" -i "${1}" -o "$(dirname "${1}")/Signed-${file}"
    fi
}

unsign ()
{
    # Determine target and un-sign as required
    file=$(basename "${1}")
    if [[ "${1}" =~ .pkg || "${1}" =~ .mpkg ]]
    then
        echo "Package found."
        /usr/sbin/pkgutil --expand "${1}" /tmp/expand.pkg
        /usr/sbin/pkgutil --flatten /tmp/expand.pkg "$(dirname "$1")/Unsigned-${file}"
    else
        echo "Code found."
        /usr/bin/openssl smime -inform DER -verify -in "${1}" -noverify -out "$(dirname "$1")/Unsigned-${file}"
        /usr/bin/plutil -convert xml1 "$(dirname "$1")/Unsigned-${file}"
    fi
}

checksign ()
{
    # Determine target and check as required
    if [[ "${1}" =~ .pkg || "${1}" =~ .mpkg ]]
    then
        echo "Package found."
        /usr/sbin/pkgutil --check-signature "${1}"
    else
        echo "Code found."
        /usr/bin/codesign -dr - --verbose=4 "${1}"
    fi
}

changemac ()
{
    # Get available interfaces
    number=1
    IFS=$'\n'
    for iface in $(/sbin/ifconfig -a | awk '/UP/ {print $1}' | sed 's/://g')
    do
        ifaces+=("${iface}")
        echo "$number) ${iface}"
        let "number += 1"
    done
    unset IFS
    echo "Select an interface: "
    read iid
    chosenIface=${ifaces[${iid}]}

    # Get MAC address or create new MAC
    newmac="${1}"
    if [[ -z "${newmac}" ]]
    then
        echo "Generating random MAC address..."
        newmac=$(/usr/bin/openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
        echo "New MAC address is ${newmac}"
    fi
    echo "Setting ${chosenIface} to ${newmac}..."
    sudo /sbin/ifconfig "${chosenIface}" ether "${newmac}"
}

makedmg ()
{
    # Determine if the content is a folder, exit if not
    if [ ! -d "${1}" ]
    then
        echo "Supplied content is not a folder. Exiting..."
    else
        dmgName=$(basename "${1}")
        dirName=$(dirname "${1}")
        hdiutil create -volname "${dmgName}" -srcfolder "${1}" -ov -format UDZO "${dirName}"/"${dmgName}".dmg
    fi
}

whatismyip ()
{
    /usr/bin/dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'
}

finduti ()
{
    /usr/bin/mdls -name kMDItemContentType "${1}"
}

exportcert ()
{
    file=$(basename "${1}")
    echo "cat /plist/dict/array/dict[1]/data/text()" | xmllint --nocdata --shell "${1}" | sed '1d;$d' | base64 -D > "$(dirname "$1")/exported-${file}.pem" 
}

generatepubkey ()
{
    /usr/bin/ssh-keygen -y -f "${1}" > "${1}".pub
}

expandurl ()
{
    curl -sIL $1 2>&1 | awk '/^Location/ {print $2}' | tail -n1
}

# findmacosinstallerversion ()
# {
#     baseSystem=$(find "${1}" -name "BaseSystem.dmg")
#     if [ $? -eq 1 ]
#     then
#         echo "Unable to find BaseSystem.dmg. Searching for InstallESD instead..."
#         installESD=$(find "${1}" -name "InstallESD.dmg")
#         if [ $? -eq 1 ]
#         then
#             echo "Unable to find InstallESD.dmg. Are you sure this is a macOS Installer?!"
#             return 1
#         else
#             installESDMounted=$(hdiutil attach "${installESD}" -nobrowse | awk -F"\t" '/\/dev\/disk/ && /Apple/ { print $NF }')
#             baseSystem=$(find "${installESDMounted}" -name "BaseSystem.dmg" | grep '.-')
#         fi
#     fi
#     basesystemMounted=$(hdiutil attach "${baseSystem}" -nobrowse | awk -F"\t" '/\/dev\/disk/ && /Apple/ { print $NF }')

#     productName=$(defaults read "${basesystemMounted}/System/Library/CoreServices/SystemVersion.plist" ProductName)
#     productBuildVersion=$(defaults read "${basesystemMounted}/System/Library/CoreServices/SystemVersion.plist" ProductBuildVersion)
#     productVersion=$(defaults read "${basesystemMounted}/System/Library/CoreServices/SystemVersion.plist" ProductVersion)

#     echo "${productName} ${productVersion}, build ${productBuildVersion}"

#     hdiutil detach "${basesystemMounted}" > /dev/null

#     if [ -e "${installESDMounted}" ]
#     then
#         hdiutil detach "${installESDMounted}" > /dev/null
#     fi
# }

removequarantine ()
{
    xattr -d com.apple.quarantine "${1}"
}

activate ()
{
    if [ -z "${1}" ]
    then
        venvdir="."
    else
        venvdir="${1}"
    fi
    
    if [ ! -e "${venvdir}/bin/activate" ]
    then
        echo "Invalid virtualenv directory. Would you like to create?"
        read yno
        case $yno in

            [yY] | [yY][Ee][Ss] )
                echo "Specify path to Python binary:" 
                read pythonBin
                pythonBin=$(which "${pythonBin}")
                if [ -e "${pythonBin}" ]
                then
                    echo "Creating virtualenv ${1} using ${pythonBin}..."
                    virtualenv -p "${pythonBin}" "${1}"
                else
                    echo "Invalid Python binary location."
                    return 1
                fi
                ;;

            [nN] | [nN][Oo] )
                yesNo="no"
                return 1
                ;;

            *)
                echo "Invalid input."
                return 1
                ;;
        esac
    fi

    source "${venvdir}/bin/activate"
}