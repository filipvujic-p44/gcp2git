#!/bin/bash
version="v1.1.0"
author="Filip Vujic"
last_updated="30-Jan-2024"
repo_owner="filipvujic-p44"
repo_name="gcp2git"
repo="https://github.com/$repo_owner/$repo_name"



###########################################################################################
###################################### Info and help ######################################
###########################################################################################



# Help text
help_text=$(cat <<EOL
GCP2GIT HELP:
-------------

Info:
-----
    gcp2git version: $version
    author: $author
    last updated: $last_updated
    github: $repo

    This script is a tool for easier downloading, syncing and comparing local, remote GitHub and GCP files.

Requirements:
-------------
    - wget (for downloading updates)
    - gcloud (for GCP access)
    - python3 (for comparing files)
    - git (for syncing with github repos)
    - bash-completion (for autocomplete)

Installation:
-------------
    Using '--install' option will create a folder ~/gcp2git and put the script inside.
    That path will be exported to ~/.bashrc so it can be used from anywhere.
    Script requires wget, gcloud, python3, git and bash-completion, so it will install those packages.
    Use '--install-y' to preapprove dependencies and run GCloud CLI login after installation.
    Using '--uninstall' will remove ~/gcp2git folder and ~/.bashrc inserts. 
    You can remove wget, gcloud, python3, git and bash-completion dependencies manually, if needed.

Options:
--------
    gcp2git.sh [-v | --version] [-h | --help] [--help-usage] [--help-gcloud-cli] 
               [--install] [--install-y] [--uninstall] [--chk-install] [--chk-for-updates] 
               [--auto-chk-for-updates-off] [--auto-chk-for-updates-on] 
               [--generate-env-file] [--update-gitignore-file] 
               [--compare] [--download] [--update] [--update-lcl-pg-gh] 
               [--ltl] [--tl] [--carrier-push] [--carrier-pull] 
               [--rating] [--dispatch] [--tracking] [--imaging] 
               [--scac <carrier_scac>] <carrier_scac>

Options (details):
------------------
    general:
        -v | --version                    Display script version and author.
        -h | --help                       Display help and usage info.
        --help-usage                      Display usage info.
        --help-gcloud-cli                 Display GCloud CLI help.
        --install                         Install script to use from anywhere in terminal.
        --install-y                       Install with preapproved dependencies and run 'gcloud auth login' after installation.
        --uninstall                       Remove changes made during install (except dependencies).
        --chk-install                     Check if script and dependencies are installed correctly.
        --chk-for-updates                 Check for new script versions.
        --auto-chk-for-updates-off        Turn off automatic check for updates (default state).
        --auto-chk-for-updates-on         Turn on automatic check for updates (checks on every run).
        --generate-env-file               Generate '.env_gcp2git' in current folder.
        --update-gitignore-file           Update '.gitignore' file.

    actions:
        --compare <env_1> <env_2>         Compare files from any two local/remote folders.
        --download <env>                  Download remote gcp files.
        --update <env_from> <env_to>      Update files from-to environment.
        --update-lcl-pg-gh <env_from>     Update local, playground and GitHub files from given environment.

    environment options:
        lcl                               Current local folder.
        gh                                Current GitHub repo.
        pg                                GCP playground.
        int                               GCP qa-integration.
        stg                               GCP qa-stage.
        sbx                               GCP sandbox.
        eu                                GCP eu-production.
        us                                GCP us-production.

    transportation-modes:
        --ltl                             Set mode to 'LTL' (default value).
        --tl                              Set mode to 'TL'.
        
    interaction-types:
        --carrier-push                    Set interaction to 'CARRIER_PUSH'.
        --carrier-pull                    Set interaction to 'CARRIER_PULL' (default value).

    service-types:
        --rating                          Set service to 'RATING'.
        --dispatch                        Set service to 'DISPATCH'.
        --tracking                        Set service to 'SHIPMENT_STATUS'.
        --imaging                         Set service to 'IMAGING'.

    carrier:
        --scac <carrier_scac>             Set carrier scac (case insensitive; can be set without using '--scac' flag).

Usage:
------
    gcp2git.sh (general-option | [transportation-mode] [interaction-type] [--scac] scac service-type action)
    gcp2git.sh abfs --imaging --compare lcl us
    gcp2git.sh --generate-env-file
    gcp2git.sh --tl --rating --download int gtjn
    gcp2git.sh --carrier-pull --dispatch --scac EXLA --update lcl pg
    gcp2git.sh --tracking --scac gtjn --update pg gh

Notes:
------
    - Tested on WSL Ubuntu 22.04 and WSL Debian 12.4
    - Default mode is 'LTL', default interaction is 'CARRIER_PULL'.
    - Carrier can be specified without using '--scac' flag and is case insensitive.
    - Flags are prioritized over .env file values.
EOL
)

# Modes text
usage_text=$(cat <<EOL
USAGE HELP:
-----------

Options:
--------
    actions:
        --compare <env_1> <env_2>         Compare files from any two local/remote folders.
        --download <env>                  Download remote gcp files.
        --update <env_from> <env_to>      Update files from-to environment.
        --update-lcl-pg-gh <env_from>     Update local, playground and GitHub files from given environment.

    environment options:
        lcl                               Current local folder.
        gh                                Current GitHub repo.
        pg                                GCP playground.
        int                               GCP qa-integration.
        stg                               GCP qa-stage.
        sbx                               GCP sandbox.
        eu                                GCP eu-production.
        us                                GCP us-production.

Usage:
------
    gcp2git.sh (general-option | [transportation-mode] [interaction-type] [--scac] scac service-type action)
    gcp2git.sh abfs --imaging --compare-lcl-and-pg
    gcp2git.sh --generate-env-file
    gcp2git.sh --tl --rating --download-pg gtjn
    gcp2git.sh --carrier-pull --dispatch --scac EXLA --update-lcl-from-int
    gcp2git.sh --tracking --scac gtjn --update-gh-from-pg

EOL
)

# GCloud CLI help text
gcloud_cli_text=$(cat <<EOL
GCLOUD CLI HELP:
----------------

Official documentation:
-----------------------
    - gsutil: https://cloud.google.com/storage/docs/gsutil
    - gsutil installation: https://cloud.google.com/sdk/docs/install
    - gcloud: https://cloud.google.com/storage/docs/discover-object-storage-gcloud
    - gcloud installaion: https://cloud.google.com/sdk/docs/install

Usage:
------
    - Login to GCloud CLI
        gcloud auth login my.email@project44.com

    - List connected accounts
        gcloud auth list

    - Change active account
        gcloud config set account my.email@project44.com

    - Revoke account
        gcloud auth revoke my.email@project44.com

    - GCloud CLI help
        gcloud help

EOL
)



############################################################################################
###################################### Vars and flags ######################################
############################################################################################



# Initialize variables to default values
flg_args_passed=false
do_install=false
do_install_y=false
do_uninstall=false
do_chk_install_=false
# ref_chk_for_updates (do not change comment)
flg_chk_for_updates=false
flg_generate_env_file=false

flg_compare_from_to_env=false
flg_download_from_env=false

flg_downloaded_playground=false
flg_downloaded_qa_int=false
flg_downloaded_qa_stage=false
flg_downloaded_sandbox=false
flg_downloaded_eu_prod=false
flg_downloaded_us_prod=false

flg_update_from_to_env=false
flg_update_lcl_pg_gh_from_env=false

gcp_pg_base_url="gs://p44-datafeed-pipeline/qa-int/src"
gcp_qa_int_base_url="gs://p44-integration-us-central1-data-feed-plan-definitions-int/qa-int/src"
gcp_qa_stage_base_url="gs://p44-staging-us-central1-data-feed-plan-definitions-staging/qa-stage/src"
gcp_sandbox_base_url="gs://p44-sandbox-us-data-feed-plan-definitions/sandbox/src"
gcp_eu_prod_base_url="gs://p44-production-eu-data-feed-plan-definitions/production-eu/src"
gcp_us_prod_base_url="gs://data-feed-plan-definitions-prod-prod-us-central1-582378/production/src"

mode="LTL"
interaction="CARRIER_PULL"
service=""
carrier=""

# Check if any args are passed to the script
if [ ! -z "$1" ]; then
    flg_args_passed=true
fi

# Load local .env_gcp2git file
if [ -e ".env_gcp2git" ]; then
    flg_args_passed=true
    source .env_gcp2git

    # Set URLs from .env

    # Load playground base URL value
    if [ ! -z "$PLAYGROUND_BASE_URL" ]; then
        playground_base_url="$PLAYGROUND_BASE_URL"
    fi

    # Load qa int base URL value
    if [ ! -z "$QA_INT_BASE_URL" ]; then
        qa_int_base_url="$QA_INT_BASE_URL"
    fi

        # Load sandbox base URL value
    if [ ! -z "$QA_STAGE_BASE_URL" ]; then
        qa_stage_base_url="$QA_STAGE_BASE_URL"
    fi

    # Load sandbox base URL value
    if [ ! -z "$SANDBOX_BASE_URL" ]; then
        sandbox_base_url="$SANDBOX_BASE_URL"
    fi

        # Load eu prod base URL value
    if [ ! -z "$EU_PROD_BASE_URL" ]; then
        eu_prod_base_url="$EU_PROD_BASE_URL"
    fi

    # Load us prod base URL value
    if [ ! -z "$US_PROD_BASE_URL" ]; then
        us_prod_url="$US_PROD_BASE_URL"
    fi

    # Set integration details from .env

    # Load mode value
    if [ ! -z "$MODE" ]; then
        mode="$MODE"
    fi

    # Load interaction value
    if [ ! -z "$INTERACTION" ]; then
        interaction="$INTERACTION"
    fi

    # Load service value
    if [ ! -z "$SERVICE" ]; then
        service="$SERVICE"
    fi

    # Load carrier value
    if [ ! -z "$SCAC" ]; then
        carrier="$SCAC"
    fi
fi

while [ "$1" != "" ] || [ "$#" -gt 0 ]; do
    case "$1" in
        -v | --version)
            echo "gcp2git version: $version"
            echo "author: $author"
            echo "last updated: $last_updated"
            echo "github: $repo"
            exit 0
            ;;
        -h | --help)
            echo "$help_text"
            exit 0
            ;;
        --help-usage)
            echo "$usage_text"
            exit 0
            ;;
        --help-gcloud-cli)
            echo "$gcloud_cli_text"
            exit 0
            ;;
        --install)
            do_install=true
            ;;
        --install-y)
            do_install_y=true
            ;;
        --uninstall)
            do_uninstall=true
            ;;
        --chk-install)
            do_chk_install=true
            ;;
        --chk-for-updates)
            flg_chk_for_updates=true
            ;;
        --auto-chk-for-updates-off)
            ref_line_number=$(grep -n "ref_chk_for_updates*" "$0" | head -n1 | cut -d':' -f1)
            line_number=$(grep -n "flg_chk_for_updates=" "$0" | head -n1 | cut -d':' -f1)
            if [ "$((line_number - ref_line_number))" -eq 1 ]; then
                sed -i "${line_number}s/flg_chk_for_updates=true/flg_chk_for_updates=false/" "$0"
                echo "Info: Auto check for updates turned off."	
            fi
            exit 0
            ;;
        --auto-chk-for-updates-on)
            ref_line_number=$(grep -n "ref_chk_for_updates*" "$0" | head -n1 | cut -d':' -f1)
            line_number=$(grep -n "flg_chk_for_updates=" "$0" | head -n1 | cut -d':' -f1)
            if [ "$((line_number - ref_line_number))" -eq 1 ]; then
                sed -i "${line_number}s/flg_chk_for_updates=false/flg_chk_for_updates=true/" "$0"
                echo "Info: Auto check for updates turned on."
            fi
            exit 0
            ;;
        --generate-env-file)
            flg_generate_env_file=true
            ;;
        --update-gitignore-file)
            flg_update_gitignore=true
            ;;
        --compare)
            flg_compare_from_to_env=true
            compare_env_1="${2}"
            compare_env_2="${3}"
            shift 2 # plus 1 after case block
            ;;
        --download)
            flg_download_from_env=true
            download_env="${2}"
            shift 1
            ;;
        --update)
            flg_update_from_to_env=true
            update_from_env="${2}"
            update_to_env="${3}"
            shift 2 # plus 1 after case block
            ;;
        --update-lcl-pg-gh)
            flg_update_lcl_pg_gh_from_env=true
            update_from_env="${2}"
            shift 1 # plus 1 after case block
            ;;
        --ltl)
            mode="LTL"
            ;;
        --tl)
            mode="TL"
            ;;
        --carrier-push)
            interaction="CARRIER_PUSH"
            ;;
        --carrier-pull)
            interaction="CARRIER_PULL"
            ;;
        --rating)
            service="RATING"
            ;;
        --dispatch)
            service="DISPATCH"
            ;;
        --tracking)
            service="SHIPMENT_STATUS"
            ;;
        --imaging)
            service="IMAGING"
            ;;
        --scac)
            carrier="${2^^}"
            shift 2 # plus 1 after case block
            ;;
        *)
            carrier="${1^^}"
            ;;
    esac
    # Since this default shift exists, all flag handling shifts are decreased by 1
    shift
done

# Set local folder paths
local_playground_folder="./downloaded_playground_${mode}_${interaction}_${service}_${carrier}"
local_qa_int_folder="./downloaded_qa_int_${mode}_${interaction}_${service}_${carrier}"
local_qa_stage_folder="./downloaded_qa_stage_${mode}_${interaction}_${service}_${carrier}"
local_sandbox_folder="./downloaded_sandbox_${mode}_${interaction}_${service}_${carrier}"
local_eu_prod_folder="./downloaded_eu_prod_${mode}_${interaction}_${service}_${carrier}"
local_us_prod_folder="./downloaded_us_prod_${mode}_${interaction}_${service}_${carrier}"

# Set full gcp urls
gcp_playground_upload_url="$gcp_pg_base_url/$mode/$service/$interaction"
gcp_playground_full_url="$gcp_pg_base_url/$mode/$service/$interaction/$carrier"
gcp_qa_int_full_url="$gcp_qa_int_base_url/$mode/$service/$interaction/$carrier"
gcp_qa_stage_full_url="$gcp_qa_stage_base_url/$mode/$service/$interaction/$carrier"
gcp_sandbox_full_url="$gcp_sandbox_base_url/$mode/$service/$interaction/$carrier"
gcp_eu_prod_full_url="$gcp_eu_prod_base_url/$mode/$service/$interaction/$carrier"
gcp_us_prod_full_url="$gcp_us_prod_base_url/$mode/$service/$interaction/$carrier"



################################################################################################
###################################### Dependency check functions ##############################
################################################################################################



# Check if wget is installed
check_wget_installed() {
    command -v wget &> /dev/null
}

# Check if GCloud CLI is installed
check_gcloud_installed() {
    command -v gcloud &> /dev/null
}

# Check if python3 is installed
check_python_installed() {
    command -v python3 &> /dev/null
}

# Check if git is installed
check_git_installed() {
    command -v git &> /dev/null
}

check_bash_completion_installed() {
    if dpkg -l | grep -q "bash-completion"; then
        return 0
    fi
    return 1
}



#################################################################################################
###################################### Install / Uninstall functions ############################
#################################################################################################



# Main installation function
install_script() {
    echo "Info: Installing gcp2git..."
    script_directory="$(dirname "$(readlink -f "$0")")"
    # Check if requirements installed
    if ! check_wget_installed || ! check_gcloud_installed || ! check_python_installed || ! check_git_installed || ! check_bash_completion_installed; then
        install_dependencies
    fi
    # Check if script already installed
    if [ -d ~/gcp2git ] && [ -f ~/gcp2git/main/gcp2git.sh ] && [ -f ~/gcp2git/util/gcp2git_autocomplete.sh ] &&
    grep -q "# gcp2git script" ~/.bashrc && grep -q 'export PATH=$PATH:~/gcp2git/main' ~/.bashrc &&
    grep -q "source ~/gcp2git/util/gcp2git_autocomplete.sh" ~/.bashrc; then
        echo "Info: Script already installed at '~/gcp2git' folder."
        echo "Q: Do you want to reinstall gcp2git? (Y/n):"
        read do_reinstall
        if [ "${do_reinstall,,}" == "n" ]; then
            echo "Info: Exited installation process. No changes made."
            exit 0
        fi
    fi
    # Clean up possible leftovers or previous installation
    clean_up_installation
    # Set up gcp2git home folder
    echo "Info: Setting up '~/gcp2git/' directory..."
    mkdir ~/gcp2git
    mkdir ~/gcp2git/main
    mkdir ~/gcp2git/util
    cp $script_directory/gcp2git.sh ~/gcp2git/main
    # Generate autocomplete script
    generate_autocomplete_script
    echo "Info: Setting up '~/gcp2git/' directory completed."
    # Set up bashrc inserts
    echo "Info: Adding paths to '~/.bashrc'..."
    echo "# gcp2git script" >> ~/.bashrc
    echo 'export PATH=$PATH:~/gcp2git/main' >> ~/.bashrc
    echo "source ~/gcp2git/util/gcp2git_autocomplete.sh" >> ~/.bashrc
    echo "Info: Paths added to '~/.bashrc'."
    # Print success message
    echo "Info: Success. Script installed in '~/gcp2git/' folder."
    # If '--install-y' was used, set up gcloud auth
    if [ "$do_install_y" == "true" ]; then
        echo "Info: Setting up GCloud CLI login..."
        echo "Q: Input your p44 email:"
        read email
        gcloud auth login $email
        if gcloud auth list | grep -q "$email"; then
            echo "Info: Logged in to GCloud CLI."
            echo "Info: Use '--help-gcloud-cli' for more info."
        else
            echo "Error: Something went wrong during GCloud CLI login attempt."
        fi
    else
        echo "Info: Use 'gcloud auth login my.email@project44.com' to login to GCloud CLI."
        echo "Info: Use 'gcloud auth list' to check if you are logged in."
        echo "Info: Use '--help-gcloud-cli' for more info."
    fi
    echo "Info: Run 'source ~/.bashrc' to apply changes in current session."
    echo "Info: Local file './gcp2git.sh' is no longer needed."
    echo "Info: Use '-h' or '--help' to get started."
    exit 0
}

install_wget() {
    echo "Info: Installing wget..."
    if [ "$do_install_y" == "true" ]; then
        sudo apt install -y wget
    else
        sudo apt install wget
    fi
    echo "Info: Wget installed."
    
}

install_gcloud() {
    if ! check_gcloud_installed; then
        sudo apt update
        echo "Info: Installing GCloud CLI..."
        # Install apt-transport-https:
        if [ "$do_install_y" == "true" ]; then
            sudo apt install -y apt-transport-https ca-certificates gnupg curl
        else
            sudo apt install apt-transport-https ca-certificates gnupg curl
        fi
        # Add the GCloud CLI distribution URI as a package source:
        if [ -f "/etc/apt/sources.list.d/google-cloud-sdk.list" ] && grep -q "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" /etc/apt/sources.list.d/google-cloud-sdk.list; then
            :
        else
            echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        fi
        # Import the Google Cloud public key:
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        # Update and install the GCloud CLI:
        sudo apt update && sudo apt install google-cloud-cli
        if command -v gcloud &> /dev/null; then
            echo "Info: GCloud CLI installed."
            echo "Info: Use 'gcloud auth login my.email@project44.com' to login to GCloud CLI."
            echo "Info: Use 'gcloud auth list' to check if you are logged in."
        else
            echo "Error: Something went wrong during installation. Consider using '--help-gcloud-cli' option and run the steps manually."
            exit 1
        fi
    else
        echo "Info: GCloud CLI already installed."
        exit 0
    fi
}

install_python() {
    echo "Info: Installing python..."
    if [ "$do_install_y" == "true" ]; then
        sudo apt install -y python3
    else
        sudo apt install python3
    fi
    echo "Info: Python installed."
}

install_git() {
    echo "Info: Installing git..."
    if [ "$do_install_y" == "true" ]; then
        sudo apt install -y git
    else
        sudo apt install git
    fi
    echo "Info: Git installed."
}

install_bash_completion() {
    echo "Info: Installing bash-completion..."
    if [ "$do_install_y" == "true" ]; then
        sudo apt install -y bash-completion
    else
        sudo apt install bash-completion
    fi
    echo "Info: Bash-completion installed."
}

install_dependencies() {
    sudo apt update
    # Check if wget is installed
    if ! check_wget_installed; then
        install_wget
    fi
    
    # Check if GCloud CLI is installed
    if ! check_gcloud_installed; then
        install_gcloud
    fi
    
    # Check if python3 is installed
    if ! check_python_installed; then
        install_python
    fi
    
    # Check if git is installed
    if ! check_git_installed; then
        install_git
    fi

    # Check if bash-completion installed
    if ! check_bash_completion_installed; then
        install_bash_completion
    fi
}

# Cleans up existing installation and leftover files/changes
clean_up_installation() {
    echo "Info: Cleaning up existing files/changes..."
    if [ -d ~/gcp2git ]; then
        rm  ~/gcp2git/main/*
        rm  ~/gcp2git/util/*
        rmdir ~/gcp2git/main
        rmdir ~/gcp2git/util
        rmdir ~/gcp2git
    fi
    if [ -f ~/.bashrc.bak ]; then
        rm ~/.bashrc.bak
        cp ~/.bashrc ~/.bashrc.bak
    fi
    sed -i "/# gcp2git script/d" ~/.bashrc
    sed -i '/export PATH=$PATH:~\/gcp2git\/main/d' ~/.bashrc
    sed -i "/source ~\/gcp2git\/util\/gcp2git_autocomplete.sh/d" ~/.bashrc
    echo "Info: Cleanup completed."
}

# Main uninstall function
uninstall_script() {
    echo "Info: Uninstaling script..."
    clean_up_installation
    echo "Info: Script required wget, gcloud, python3, git and bash-completion installed."
    echo "Info: You can remove these packages manually if needed."
    echo "Info: Uninstall completed."
    exit 0
}

# Download and install updates
# $1 - remote version
install_updates() {
    # Check arg count and npe, assign values
    check_args 1 $@
    local remote_version=$1
    # Function logic
    update_url="https://github.com/$repo_owner/$repo_name/archive/refs/tags/v$remote_version.tar.gz"
    tmp_folder="tmp_gcp2git_$remote_version"
    if [ -d "tmp_folder" ]; then
        rm -r "$tmp_folder"
    fi
    echo "Info: Downloading latest version..."
    wget -q -P "$tmp_folder" "$update_url"
    echo "Info: Download completed."
    echo "Info: Extracting..."
    cd "$tmp_folder"
    tar -xzf "v$remote_version.tar.gz"
    rm "v$remote_version.tar.gz"
    echo "Info: Extraction completed."
    cd "gcp2git-$remote_version"
    ./gcp2git.sh --install
    cd ../..
    rm -r "$tmp_folder"
}

# Generates autocomplete script in install folder
generate_autocomplete_script() {
    echo "Info: Generating 'gcp2git_autocomplete.sh' script..."
    completion_text=$(cat <<EOL
#!/bin/bash

autocomplete() {
    local cur prev words cword
    _init_completion || return

    local options="--version -v --chk-for-updates --auto-chk-for-updates-off --auto-chk-for-updates-on "
    options+="--help -h --help-gcloud-cli --help-usage --install --install-y --uninstall --chk-install --generate-env-file "
    options+="--update-gitignore-file --compare --download --update --update-lcl-pg-gh "
    options+="--ltl --tl --carrier-push --carrier-pull --rating --dispatch --tracking --imaging --scac"

    # Check if --compare is present in the command line arguments
    if [[ " \${COMP_WORDS[@]} " =~ " --compare " ]]; then
        COMPREPLY=("lcl" "pg" "int" "stg" "sbx" "eu" "us" \$(compgen -o plusdirs -o nospace -W "\$(_filedir)" -- "\${cur}"))
    elif [[ "\${COMP_WORDS[@]} " =~ " --download " ]]; then
            COMPREPLY=("pg" "int" "stg" "sbx" "eu" "us")
    elif [[ "\${COMP_WORDS[@]} " =~ " --update " ]]; then
        local first_param=("lcl" "pg" "int" "stg" "sbx" "eu" "us")
        local second_param=("lcl" "pg" "gh")

        case "\${COMP_WORDS[\${#COMP_WORDS[@]}-2]}" in
            *lcl*|*pg*|*int*|*stg*|*sbx*|*eu*|*us*)
                COMPREPLY=(\$(compgen -W "\${second_param[*]}" -- "\${cur}"))
                ;;
            *)
                COMPREPLY=(\$(compgen -W "\${first_param[*]}" -- "\${cur}"))
                ;;
        esac
    elif [[ "\${COMP_WORDS[@]} " =~ " --update-lcl-pg-gh " ]]; then
            COMPREPLY=("int" "stg" "sbx" "eu" "us")
    else
        COMPREPLY=(\$(compgen -W "\$options" -- "\${cur}"))
    fi

    return 0
}

complete -F autocomplete gcp2git.sh
EOL
)
    echo "$completion_text" >> ~/gcp2git/util/gcp2git_autocomplete.sh
    chmod +x ~/gcp2git/util/gcp2git_autocomplete.sh
    echo "Info: Generated 'gcp2git_autocomplete.sh' script."
}

# Generates .env_gcp2git file in current folder
generate_env_file() {
    echo "Info: Generating '.env_gcp2git' file..."
    if [ -f "./.env_gcp2git" ]; then
        rm ./.env_gcp2git
    fi
    env_text=$(cat <<EOL
#!/bin/bash
# version="$version"
# author="$author"
# last_updated="$last_updated"
# github="$repo"

# URLS (defaults: already set)
PLAYGROUND_BASE_URL=""
QA_INT_BASE_URL=""
QA_STAGE_BASE_URL=""
SANDBOX_BASE_URL=""
EU_PROD_BASE_URL=""
US_PROD_BASE_URL=""

# INTEGRATION DETAILS (defaults: MODE=LTL, INTERACTION=CARRIER_PULL)
# Fields can be overridden by flags
# Modes  = [ LTL, TL ]
MODE=""
# Interactions = [ CARRIER_PULL, CARRIER_PUSH  ]
INTERACTION=""
# Services = [ RATING, DISPATCH, TRACKING, IMAGING ]
SERVICE="MY_SERVICE"
# Carrier scac
SCAC="MY_SCAC"
EOL
)
    echo "$env_text" >> ./.env_gcp2git
    echo "Info: Generated '.env_gcp2git' file."
}


#####################################################################################################
###################################### General check functions ######################################
#####################################################################################################


# Check if there is a new release on gcp2git GitHub repo
check_for_updates() {
    # Local script version
    local local_version=$(echo "$version" | sed 's/^v//')
    # Latest release text
    local latest_text=$(curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest")
    # Latest remote version
    local remote_version=$(echo "$latest_text" | grep "tag_name" | sed 's/.*"v\([0-9.]*\)".*/\1/' | cat)
    # Check if versions are different
    local version_result=$(
        awk -v v1="$local_version" -v v2="$remote_version" '
            BEGIN {
                if (v1 == v2) {
                    result = 0;
                    exit;
                }
                split(v1, a, ".");
                split(v2, b, ".");
                for (i = 1; i <= length(a); i++) {
                    if (a[i] < b[i]) {
                        result = 1;
                        exit;
                    } else if (a[i] > b[i]) {
                        result = 2;
                        exit;
                    }
                }
                result = 0;
                exit;
            }
            END {
                print result
            }'
    )   
    
    if [ "$version_result" -eq 0 ]; then
        echo "Info: You already have the latest script version ($version)."
    elif [ "$version_result" -eq 1 ]; then
        local release_notes=$(echo "$latest_text" | grep "body" | sed -n 's/.*"body": "\([^"]*\)".*/\1/p' | sed 's/\\r\\n/\n/g' | cat)
        echo "Info: New version available (v$remote_version). Your version is (v$local_version)."
        echo "Info: Release notes:"
        echo "$release_notes"
        echo "Info: Visit '$repo/releases' for more info."
        echo "Q: Do you want to download and install updates? (Y/n):"
        read do_update
        if [ "${do_update,,}" == "y" ] || [ -z "$do_update" ]; then
            install_updates "$remote_version"
        else
            echo "Info: Update canceled."
        fi
    elif [ "$version_result" -eq 2 ]; then
        echo "Info: You somehow have a version that hasn't been released yet ;)"
        echo "Info: Latest release is (v$remote_version). Your version is (v$local_version)."
    fi
}

# Check if all necessary changes are done during installation
check_installation() {
    local cnt_missing=0
    if check_wget_installed; then
        echo "Info: wget ------------------- OK."
    else
        echo "Error: wget ------------------ NOT FOUND."
        ((cnt_missing++))
    fi

    if check_gcloud_installed; then
        echo "Info: gcloud ----------------- OK."
    else
        echo "Error: gcloud ---------------- NOT FOUND."
        ((cnt_missing++))
    fi

    if check_python_installed; then
        echo "Info: python3 ---------------- OK."
    else
        echo "Error: python3 --------------- NOT FOUND."
        ((cnt_missing++))
    fi

    if check_git_installed; then
        echo "Info: git -------------------- OK."
    else
        echo "Error: git ------------------- NOT FOUND."
        ((cnt_missing++))
    fi

    if check_bash_completion_installed; then
        echo "Info: bash-completion -------- OK."
    else
        echo "Error: bash-completion ------- NOT FOUND."
        ((cnt_missing++))
    fi
        
    if [ -d ~/gcp2git ] && [ -f ~/gcp2git/main/gcp2git.sh ] && [ -f ~/gcp2git/util/gcp2git_autocomplete.sh ]; then
        echo "Info: ~/gcp2git/ ------------- OK."
    else
        echo "Error: ~/gcp2git/ ------------ NOT OK."
        ((cnt_missing++))
    fi

    if grep -q "# gcp2git script" ~/.bashrc && grep -q 'export PATH=$PATH:~/gcp2git/main' ~/.bashrc &&
        grep -q "source ~/gcp2git/util/gcp2git_autocomplete.sh" ~/.bashrc; then
        echo "Info: ~/.bashrc -------------- OK."
    else
        echo "Error: ~/.bashrc ------------- NOT OK."
        ((cnt_missing++))
    fi	

    if [ "$cnt_missing" -gt "0" ]; then
        echo "Error: Problems found. Use '--install' or '--install-y' to (re)install the script."
        return 1
    fi
    return 0
}

# Check if the required number of args is passed to a function
# $1 - required number of args
# $2 - all passed args
check_args() {
        local parent_func="${FUNCNAME[1]}"
        local required_number_of_args=$1
        shift;
        local total_number_of_args=$#
        local args=$@
        if [ $total_number_of_args == 0 ] || [ -z $total_number_of_args ]; then
            echo "Error: No arguments provided!"
            exit 1
        fi
        if [ $total_number_of_args -ne $required_number_of_args ]; then
            echo "Error: Function '$parent_func' required $required_number_of_args arguments but $total_number_of_args provided!"
            exit 1
        fi
        for arg in $args; do
            if [ -z "$arg" ]; then
                    echo "Error: Argument cannot be null or empty!"
            exit 1
            fi
        done
}

# Checks if a file starts with any of the prefixes.
# $1 - local file name
check_file_prefix() {
    # Check arg count and npe, assign values
    check_args 1 $@
    local filename=$1
    # Function logic
    local prefixes=("dataFeedPlan" "valueTranslations" "controlTemplate" "headerTemplate" "uriTemplate" "requestBodyTemplate" "responseBodyTemplate")
    for prefix in "${prefixes[@]}"; do
        if [[ "$filename" == "$prefix"* ]]; then
            return 0
        fi
    done
    return 1
}

# Check if current directory is a git repo.
check_is_git_repo() {
    if [ -d ".git" ] && [ "$(git rev-parse --is-inside-work-tree)" == "true" ]; then
           return 0
       else
        return 1
    fi
}

# Check all git requirements.
check_git_repo_requirements() {
    if ! check_git_installed; then
        echo "Error: Git is not installed!"
        exit 1
    fi
    if ! check_is_git_repo; then
        echo "Error: Directory is not a git repo!"
        exit 1
    fi
}

# Check if carrier scac is provided
check_carrier_set() {
    if [ -z "$carrier" ]; then
        return 1
    fi
    return 0
}

# Check if service name is provided
check_service_set() {
    if [ -z "$service" ]; then
        return 1
    fi
    return 0
}

# Check if all dependencies are installed
check_dependencies() {
    if ! check_wget_installed; then
        echo "Info: Wget is not installed. Installing updates may not work properly."
    fi

    if ! check_gcloud_installed; then
        echo "Info: GCloud CLI is not installed. You may not have access to GCP."
    fi

    if ! check_python_installed; then
        echo "Info: Python is not installed. Comparing files may not work properly."
    fi

    if ! check_git_installed; then
        echo "Info: Git is not installed. Syncing with GitHub may not work properly."
    fi

    if ! check_bash_completion_installed; then
        echo "Info: Bash-completion is not installed. It is not required, but you won't have command completion."
    fi
}

# Check requirements before calling any action
check_action_requirements() {
    if ! check_carrier_set; then
        echo "Error: No carrier scac provided!"
        exit 1
    fi
    
    if ! check_service_set; then
        echo "Error: No service name provided!"
        exit 1
    fi
}



###############################################################################################
###################################### Utility functions ######################################
###############################################################################################



# Downloads files from GCP.
# $1 - gcp url (environment)
# $2 - local target folder
download_from_gcp() {
    # Check arg count and npe, assign values
    check_args 2 $@
    local gcp_url=$1
    local local_folder=$2
    # Function logic
    gsutil -q -m cp -r "$gcp_url" "$local_folder"
}

# Uploads files to GCP.
# $1 - local file name
# $2 - gcp url (environment)
upload_file_to_gcp() {
    # Check arg count and npe, assign values
    check_args 2 $@
    local filename=$1
    local gcp_url=$2
    # Function logic
    if [ -d "$filename" ]; then
        gsutil -q cp -r "$filename" "$gcp_url"
    else
        gsutil -q cp "$filename" "$gcp_url"
    fi
}

# Checks file content differences between two folders.
# $1 - source folder to iterate over
# $2 - target folder to search for files and check content
compare_files() {
    # Check arg count and npe, assign values
    check_args 2 $@
    local source_folder=$1
    local target_folder=$2
    # Function logic
    local diffCount=0;
    for source_file in "$source_folder"/*; do
        # Check if it's a file
        if [ -f "$source_file" ]; then
            # Extract the filename from the path
            filename=$(basename "$source_file")
            if check_file_prefix "$filename"; then
                target_folder_file_path="$target_folder/$filename"
                # Check if target file exists
                if [ ! -f "$target_folder_file_path" ]; then
                    echo "Error: File $target_folder_file_path doesn't exist!"
                    ((diffCount++))
                # If it exists, compare files
                elif cmp -s "$source_file" "$target_folder_file_path" || diff -q "$source_file" "$target_folder_file_path" > /dev/null; then
                    :
                # If files are .json type, try to fix the formatting
                elif [[ "$source_file" == *.json ]] &&
                    diff <(cat "$source_file" | python3 -m json.tool) <(cat "$target_folder_file_path" | python3 -m json.tool) &> /dev/null; then
                    echo "Info: File '$filename' has matching content, but different formatting."
                    ((diffCount++))
                else
                    # Handle file diff
                    echo "Info: File '$filename' doesn't have matching content."
                    echo "Q: Show diff (y/N)?"
                    read show_diff
                    if [ "${show_diff,,}" == "y" ]; then
                        # Print lines that your local file contains, but the remote one doesn't
                        echo "Info: File content: '$source_file':"
                        grep -nFxvf "$target_folder_file_path" "$source_file"
                        # Print lines that the remote file contains, but your local one doesn't
                        echo "Info: File content: '$target_folder_file_path':"
                        grep -nFxvf "$source_file" "$target_folder_file_path"
                        
                    fi
                    ((diffCount++))
                fi
            fi
        fi
    done
    if [ "$diffCount" -eq 1 ]; then
        echo "Info: Found differences in 1 file."
    elif [ "$diffCount" -gt 0 ]; then
        echo "Info: Found differences in $diffCount files."
    else
        echo "Info: All files have matching content."
    fi
}

# Updates content of files using another folder as source.
# $1 - source folder with new content
# $2 - destination folder containing files that will get updated
update_file_content() {
    # Check arg count and npe, assign values
    check_args 2 $@
    local source_folder=$1
    local destination_folder=$2
    # Function logic
    # Loop through the files in the source folder
    for source_file in "$source_folder"/*; do
        # Check if it's a file
        if [ -f "$source_file" ]; then
            # Extract the filename from the path
            filename=$(basename "$source_file")

            # Construct the destination path by appending the filename to the destination folder
            destination_path="$destination_folder/$filename"
            # Check if the destination file exists
            if [ ! -e "$destination_path" ]; then
                echo "Info: Destination file '$destination_path' does not exist. Creating '$filename' in '$destination_folder'."
                cp "$source_file" "$destination_folder"
            # Update local files if flag set
            elif [ -e "$destination_path" ]; then
                # Copy the content of the source file to the destination file
                cat "$source_file" > "$destination_path"
                echo "Info: Copied content of '$source_file' to '$destination_path'."
            else
                :
            fi
        fi
    done
}

# Updates local files from source folder.
# $1 - source folder with new files
update_local_from_source() {
    # Check arg count and npe, assign values
    check_args 1 $@
    local source_folder=$1
    local destination_folder="."
    # Function logic
    echo "Info: Updating files in '$destination_folder' using '$source_folder' files."
    update_file_content $source_folder $destination_folder
}

# Uploads files to GCP playground.
# $1 - source folder containing files to be uploaded
upload_to_pg() {
    # Check arg count and npe, assign values
    check_args 1 $@
    local source_folder=$1
    # Function logic
    local tmp_dir="./tmp_$carrier"
    if [ -d "$tmp_dir" ]; then
        rm -rf "$tmp_dir"
    fi
    mkdir "$tmp_dir"
    mkdir "$tmp_dir/$carrier"
    for source_file in "$source_folder"/*; do
        if [ -f "$source_file" ]; then
            filename=$(basename "$source_file")
            if check_file_prefix "$filename"; then
                cp "$filename" "$tmp_dir/$carrier/"
                echo "Info: Processing $filename for upload."
            fi
        fi
    done
    upload_file_to_gcp "$tmp_dir/$carrier" "$gcp_playground_upload_url"
    echo "Info: Uploaded files to GCP playground"
    rm -rf "$tmp_dir"
}

# Updates .gitignore file.
update_gitignore() {
    # Git repo requirements check
    check_git_repo_requirements	
    # Function logic
    if [ -f ".gitignore" ]; then
        if grep -q "gcp2git.sh" .gitignore; then
            :
        else
            echo "Info: Adding 'gcp2git.sh' to .gitignore."
            echo "gcp2git.sh" >> .gitignore
        fi
        if grep -q ".env_gcp2git" .gitignore; then
            :
        else
            echo "Info: Adding '.env_gcp2git' to .gitignore."
            echo ".env_gcp2git" >> .gitignore
        fi
        if grep -q "downloaded_playground_*" .gitignore; then
            :
        else
            echo "Info: Adding 'downloaded_playground_*' to .gitignore."
            echo "downloaded_playground_*" >> .gitignore
        fi
        if grep -q "downloaded_qa_int_*" .gitignore; then
            :
        else
            echo "Info: Adding 'downloaded_qa_int_*' to .gitignore."
            echo "downloaded_qa_int_*" >> .gitignore
        fi
    else
        echo "Info: Creating a .gitignore file"
        touch .gitignore
        echo "Info: Adding 'gcp2git.sh' to .gitignore."
        echo "gcp2git.sh" >> .gitignore
        echo "Info: Adding '.env_gcp2git' to .gitignore."
        echo ".env_gcp2git" >> .gitignore
        echo "Info: Adding 'downloaded_playground_*' to .gitignore."
        echo "downloaded_playground_*" >> .gitignore
        echo "Info: Adding 'downloaded_qa_int_*' to .gitignore."
        echo "downloaded_qa_int_*" >> .gitignore
    fi
}

# Commits git changes.
commit_git() {
    # Git requirement check
    check_git_repo_requirements
    # Function logic
    echo "Q: Input commit message (if empty, default is '{current_branch} gcp2git sync'):"
    read commit_msg
    git add . ':(exclude)gcp2git.sh' ':(exclude).env_gcp2git' ':(exclude)downloaded_playground_*' ':(exclude)downloaded_qa_int_*'
    if [ -z $commit_msg ]; then
        git commit -m "$(git branch --show-current) gcp2git sync"
    else
        git commit -m "$commit_msg"
    fi
    echo "Q: Do you want to push changes to remote? (Y/n):"
    read push_changes
    if [ "${push_changes,,}" == "y" ] || [ -z $push_changes ]; then
        git push origin "$(git branch --show-current)"
    else
        :
    fi
}



###################################################################################################
###################################### Implemented action functions ###############################
###################################################################################################



# Compare files from two local/remote folders
# $1 - first environment for comparison
# $2 - second environment for comparison
compare_envs() {
    # Check arg count and npe, assign values
    check_args 2 $@
    local compare_env_1=$1
    local compare_env_2=$2
    # Function logic
    if [ "$compare_env_1" == "$compare_env_2" ]; then
        echo "Error: Same value '$compare_env_1' provided for source and target folder/environment!"
        exit 1
    fi
    if [ ! -d "$compare_env_1" ]; then
        case "$compare_env_1" in
            "lcl")
                compare_env_1="."
                ;;
            "pg")
                compare_env_1="$local_playground_folder"
                download_from_env "pg"
                ;;
            "int")
                compare_env_1="$local_qa_int_folder"
                download_from_env "int"
                ;;
            "stg")
                compare_env_1="$local_stage_folder"
                download_from_env "stg"
                ;;
            "sbx")
                compare_env_1="$local_sandbox_folder"
                download_from_env "sbx"
                ;;
            "eu")
                compare_env_1="$local_eu_prod_folder"
                download_from_env "eu"
                ;;
            "us")
                compare_env_1="$local_us_prod_folder"
                download_from_env "us"
                ;;
            *)
                compare_env_1="."
                ;;
        esac
    fi
    if [ ! -d "$compare_env_2" ]; then
        case "$compare_env_2" in
            "lcl")
                compare_env_1="."
                ;;
               "pg")
                compare_env_2="$local_playground_folder"
                download_from_env "pg"
                ;;
            "int")
                compare_env_2="$local_qa_int_folder"
                download_from_env "int"
                ;;
            "stg")
                compare_env_2="$local_stage_folder"
                download_from_env "stg"
                ;;
            "sbx")
                 compare_env_2="$local_sandbox_folder"
                 download_from_env "sbx"
                 ;;
            "eu")
                compare_env_2="$local_eu_prod_folder"
                download_from_env "eu"
                ;;
            "us")
                compare_env_2="$local_us_prod_folder"
                download_from_env "us"
                ;;
            *)
                compare_env_2="."
                ;;
        esac
    fi
    echo "Info: Comparing folders '$compare_env_1' and '$compare_env_2'."
    compare_files "$compare_env_1" "$compare_env_2"
}

# Download from any env
# $1 - source environment to download from
download_from_env() {
    # Check arg count and npe, assign values
    check_args 1 $@
    local download_env=$1
    # Function logic
    case "$download_env" in
        "pg")
            if [ "$flg_downloaded_playground" == "true" ]; then
                break
               fi
            echo "Info: Downloading GCP playground files."
            if [ -d "$local_playground_folder" ] && [ "$flg_fresh_gcp_pg_download" != "true" ]; then
                rm -r "$local_playground_folder"
                mkdir "$local_playground_folder"
            else
                mkdir "$local_playground_folder"
            fi
            if [ "$carrier" == "*" ]; then
                   download_from_gcp "$gcp_playground_full_url" "$local_playground_folder"
               else
                   download_from_gcp "$gcp_playground_full_url/*" "$local_playground_folder"
               fi
               flg_downloaded_playground=true
            ;;
        "int")
            if [ "$flg_downloaded_qa_int" == "true" ]; then
                break
               fi
            echo "Info: Downloading GCP qa-int files."
              if [ -d "$local_qa_int_folder" ] && [ "$flg_fresh_gcp_qa_int_download" != "true" ]; then
                  rm -r "$local_qa_int_folder"
                  mkdir "$local_qa_int_folder"
              else
                  mkdir "$local_qa_int_folder"
              fi
              if [ "$carrier" == "*" ]; then
                     download_from_gcp "$gcp_qa_int_full_url" "$local_qa_int_folder"
                 else
                     download_from_gcp "$gcp_qa_int_full_url/*" "$local_qa_int_folder"
                 fi
                 flg_downloaded_qa_int=true
            ;;
        "stg")
               if [ "$flg_downloaded_qa_stage" == "true" ]; then
                   break
                  fi
            echo "Info: Downloading GCP qa-stage files."
               if [ -d "$local_qa_stage_folder" ] && [ "$flg_fresh_gcp_qa_stage_download" != "true" ]; then
                   rm -r "$local_qa_stage_folder"
                   mkdir "$local_qa_stage_folder"
               else
                   mkdir "$local_qa_stage_folder"
               fi
               if [ "$carrier" == "*" ]; then
                      download_from_gcp "$gcp_qa_stage_full_url" "$local_qa_stage_folder"
                  else
                      download_from_gcp "$gcp_qa_stage_full_url/*" "$local_qa_stage_folder"
                  fi
                  flg_downloaded_qa_stage=true
            ;;
        "sbx")
            if [ "$flg_downloaded_sandbox" == "true" ]; then
                   break
                  fi
            echo "Info: Downloading GCP sandbox files."
               if [ -d "$local_sandbox_folder" ] && [ "$flg_fresh_gcp_sandbox_download" != "true" ]; then
                   rm -r "$local_sandbox_folder"
                   mkdir "$local_sandbox_folder"
               else
                   mkdir "$local_sandbox_folder"
               fi
               if [ "$carrier" == "*" ]; then
                      download_from_gcp "$gcp_sandbox_full_url" "$local_sandbox_folder"
                  else
                      download_from_gcp "$gcp_sandbox_full_url/*" "$local_sandbox_folder"
                  fi
                  flg_downloaded_sandbox=true
            ;;
        "eu")
            if [ "$flg_downloaded_eu_prod" == "true" ]; then
                       break
               fi
            echo "Info: Downloading GCP eu-prod files."
               if [ -d "$local_eu_prod_folder" ] && [ "$flg_fresh_gcp_eu_prod_download" != "true" ]; then
                   rm -r "$local_eu_prod_folder"
                   mkdir "$local_eu_prod_folder"
               else
                   mkdir "$local_eu_prod_folder"
               fi
               if [ "$carrier" == "*" ]; then
                      download_from_gcp "$gcp_eu_prod_full_url" "$local_eu_prod_folder"
                  else
                      download_from_gcp "$gcp_eu_prod_full_url/*" "$local_eu_prod_folder"
                  fi
                  flg_downloaded_eu_prod=true
            ;;
        "us")
            if [ "$flg_downloaded_us_prod" == "true" ]; then
                      break
               fi
            echo "Info: Downloading GCP us-prod files."
              if [ -d "$local_us_prod_folder" ] && [ "$flg_fresh_gcp_us_prod_download" != "true" ]; then
                  rm -r "$local_us_prod_folder"
                  mkdir "$local_us_prod_folder"
              else
                  mkdir "$local_us_prod_folder"
              fi
              if [ "$carrier" == "*" ]; then
                     download_from_gcp "$gcp_us_prod_full_url" "$local_us_prod_folder"
                 else
                     download_from_gcp "$gcp_us_prod_full_url/*" "$local_us_prod_folder"
                 fi
                 flg_downloaded_us_prod=true
            ;;
        *)
            echo "Error: Environment '$download_env' not found!"
            exit 1
            ;;
    esac
}

# Update files from/to environment
# $1 - source environment to copy files from
# $2 - target environment to update files
update_from_to_env() {
    # Check arg count and npe, assign values
    check_args 2 $@
    local update_from_env=$1
    local update_to_env=$2
    local from_folder=""
    # Function logic
    if [ "$update_from_env" == "$update_to_env" ]; then
        echo "Error: Same value '$update_from_env' provided for source and target environment!"
        exit 1
    fi
    case "$update_from_env" in
            "lcl")
                from_folder="."
                ;;
            "pg")
                download_from_env "pg"
                from_folder="$local_playground_folder"
                ;;
            "int")
                download_from_env "ing"
                from_folder="$local_qa_int_folder"
                ;;
            "stg")
                download_from_env "stg"
                from_folder="$local_stage_folder"
                ;;
            "sbx")
                download_from_env "sbx"
                from_folder="$local_sandbox_folder"
                ;;
            "eu")
                download_from_env "eu"
                from_folder="$local_eu_prod_folder"
                ;;
            "us")
                download_from_env "us"
                from_folder="$local_us_prod_folder"
                ;;
            *)
                echo "Error: Update from environment '$update_from_env' not supported!"
                exit 1
                ;;
        esac
        case "$update_to_env" in
               "lcl")
                update_local_from_source "$from_folder"
                ;;
            "pg")
                upload_to_pg "$from_folder"
                ;;
            "gh")
                update_local_from_source "$from_folder"
                update_gitignore
                   commit_git
                ;;
            *)
                echo "Error: Update to environment '$update_to_env' not supported!"
                   exit 1
                ;;
        esac
}

# Update local, playground and GitHub files from given environment
# $1 - source environment to copy files from 
update_lcl_pg_gh_from_env() {
    # Check arg count and npe, assign values
    check_args 1 $@
    local update_from_env=$1
    local from_folder=""
    # Function logic
    case "$update_from_env" in
        "int")
            download_from_env "ing"
            from_folder="$local_qa_int_folder"
            ;;
        "stg")
            download_from_env "stg"
            from_folder="$local_stage_folder"
            ;;
        "sbx")
            download_from_env "sbx"
            from_folder="$local_sandbox_folder"
            ;;
        "eu")
            download_from_env "eu"
            from_folder="$local_eu_prod_folder"
            ;;
        "us")
            download_from_env "us"
            from_folder="$local_us_prod_folder"
            ;;
        *)
            echo "Error: Update from environment '$update_from_env' not supported!"
            exit 1
            ;;
    esac
    update_local_from_source "$from_folder"
    upload_to_pg "$from_folder"
    update_gitignore
    commit_git
}




###########################################################################################################################
############################################ Flags checks and function calls ##############################################
###########################################################################################################################



# General

# If any args are passed, check if dependencies are installed
if [ "$flg_args_passed" == "true" ]; then
    check_dependencies
fi

# Check for updates
if [ "$flg_chk_for_updates" == "true" ]; then
    check_for_updates
    exit 0
fi

# Install
if [ "$do_install" == "true" ] || [ "$do_install_y" == "true" ]; then
    install_script
    exit 0
fi

# Uninstall
if [ "$do_uninstall" == "true" ]; then
    uninstall_script
    exit 0
fi

# Install GCloud CLI
if [ "$do_chk_install" == "true" ]; then
    check_installation
    exit 0
fi

# Generate env file
if [ "$flg_generate_env_file" == "true" ]; then
    generate_env_file
    exit 0
fi

# Update gitignore file
if [ "$flg_update_gitignore" == "true" ]; then
    update_gitignore
    exit 0
fi

# If any args are passed, check if carrier scac and service name are set
if [ "$flg_args_passed" == "true" ]; then
    check_action_requirements
fi

# Action calls

# Compare environments
if [ "$flg_compare_from_to_env" == "true" ]; then
    compare_envs "$compare_env_1" "$compare_env_2"
fi

# Download from GCP env
if [ "$flg_download_from_env" == "true" ]; then
    download_from_env "$download_env"
fi

# Update from/to env
if [ "$flg_update_from_to_env" == "true" ]; then
    update_from_to_env "$update_from_env" "$update_to_env"
fi

# Update local, GitHub and playground from env
if [ "$flg_update_lcl_pg_gh_from_env" == "true" ]; then
    update_lcl_pg_gh_from_env "$update_from_env"
fi



###################################################################################################
############################################ Cleanup ##############################################
###################################################################################################



# Remove local playground download folder
if [ -d "$local_playground_folder" ] && { [ "$flg_download_from_env" != "true" ] || [ -z "$(ls -A "$local_playground_folder")" ]; }; then
    rm -r "$local_playground_folder"
fi

# Remove local qa-int download folder
if [ -d "$local_qa_int_folder" ] && { [ "$flg_download_from_env" != "true" ] || [ -z "$(ls -A "$local_qa_int_folder")" ]; }; then
    rm -r "$local_qa_int_folder"
fi

# Remove local qa stage download folder
if [ -d "$local_qa_stage_folder" ] && { [ "$flg_download_from_env" != "true" ] || [ -z "$(ls -A "$local_qa_stage_folder")" ]; }; then
    rm -r "$local_qa_stage_folder"
fi

# Remove local sandbox download folder
if [ -d "$local_sandbox_folder" ] && { [ "$flg_download_from_env" != "true" ] || [ -z "$(ls -A "$local_sandbox_folder")" ]; }; then
    rm -r "$local_sandbox_folder"
fi

# Remove local eu prod download folder
if [ -d "$local_eu_prod_folder" ] && { [ "$flg_download_from_env" != "true" ] || [ -z "$(ls -A "$local_eu_prod_folder")" ]; }; then
    rm -r "$local_eu_prod_folder"
fi

# Remove local us prod download folder
if [ -d "$local_us_prod_folder" ] && { [ "$flg_download_from_env" != "true" ] || [ -z "$(ls -A "$local_us_prod_folder")" ]; }; then
    rm -r "$local_us_prod_folder"
fi


echo "Info: Script completed."
