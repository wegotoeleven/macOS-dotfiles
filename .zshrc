# Exports

export PATH=$HOME/.binaries:$HOME/.homebrew/bin:$PATH
export CLICOLOR=1
export HISTSIZE=100000
export SAVEHIST=1000000

# # # Options

setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_NO_STORE


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
        /usr/bin/productsign --sign "${chosenCert}" "${1}" $(dirname "${1}")/Signed-"${file}"
    else
        echo "Signing code..."
        /usr/bin/security cms -S -N "${chosenCert}" -i "${1}" -o $(dirname "${1}")/Signed-"${file}"
    fi    
}

unsign ()
{
    file=$(basename "${1}")
    if [[ "${1}" =~ .pkg || "${1}" =~ .mpkg ]]
    then
        echo "Package found."
        /usr/sbin/pkgutil --expand "${1}" /tmp/expand.pkg
        /usr/sbin/pkgutil --flatten /tmp/expand.pkg $(dirname "$1")/Unsigned-"${file}"
    else
        echo "Code found."
        /usr/bin/openssl smime -inform DER -verify -in "${1}" -noverify -out $(dirname "$1")/Unsigned-"${file}"
        /usr/bin/plutil -convert xml1 $(dirname "$1")/Unsigned-"${file}"
    fi   
}

checksign ()
{
    if [[ "${1}" =~ .pkg || "${1}" =~ .mpkg ]]
    then
        echo "Package found."
        /usr/sbin/pkgutil --check-signature "${1}"
    else
        echo "Code found."
        /usr/bin/codesign -dr - --verbose=4 "${1}"
    fi
}
