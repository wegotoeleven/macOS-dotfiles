# Exports
export PATH=$HOME/.binaries:$HOME/.homebrew/bin:$PATH
export FPATH=$HOME/.zsh:$FPATH
export CLICOLOR=1
export HISTSIZE=100000
export SAVEHIST=1000000

# Options
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_NO_STORE
setopt PROMPT_SUBST

# Plugins
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
    for cert in $(/usr/bin/security find-certificate -a -c Developer | awk -F '=' '/"alis"/ {print $2}' | sed 's/"//g')
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
    /usr/bin/mdls -name kMDItemContentTypeTree "${1}"
}

exportcert ()
{
    file=$(basename "${1}")
    echo "cat /plist/dict/array/dict[1]/data/text()" | xmllint --nocdata --shell "${1}" | sed '1d;$d' | base64 -D > "$(dirname "$1")/exported-${file}.pem" 
}

expandurl ()
{
    curl -sIL $1 2>&1 | awk '/^Location/ {print $2}' | tail -n1
}

# createvenv ()
# {
#     pyVer=(python python3)
#     for pyVerChoice in '${pyVer}'
#     do
#         pyVerChosen+=("${pyVerChoice}")
#         echo "$number) ${pyverChoice}"
#         let "number += 1"
#     done
#     currentDir="$(pwd)"
#     venvName=$(basename "$(echo ${currentDir})")
#     # if [[ "${1}" == "python1" ]]
#     # then
#     #     python -m virtualenv "${currentDir}"
#     # else
#     #     python3 -m venv "${currentDir}"
#     # fi
# }

# check-version ()
# {
#     defaults read "${1}/Contents/Info.plist" CFBundleShortVersionString
#     defaults read "${1}/Contents/Info.plist" CFBundleVersion
# }
#
# check-identifier ()
# {
#     defaults read "${1}/Contents/Info.plist" CFBundleIdentifier
# }
