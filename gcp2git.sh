#!/bin/bash
version="v1.0.14"
author="Filip Vujic"
last_updated="23-Dec-2023"
repo_owner="filipvujic-p44"
repo_name="gcp2git"
repo="https://github.com/$repo_owner/$repo_name"

###################################################################################
###################################### To Do ######################################
###################################################################################


# verbose mode
# log mode
# dynamic env file name


###########################################################################################
###################################### Info and help ######################################
###########################################################################################


# Help text
help_text=$(cat <<EOL
INFO:
  gcp2git version: $version
  author: $author
  last updated: $last_updated
  github: $repo

  This script is used as a tool for easier downloading, syncing and comparing local, remote GitHub and GCP files.
  
  Script requires that you are logged into GCloud CLI (check with 'gcloud auth list').
  For more info on how to set up GCloud CLI use '--help-gcloud-cli' or read:
  https://drive.google.com/file/d/1k1YHjEFtCLE3DpbZ7Tl_99eYoe3tx4C8/view?usp=sharing.

REQUIREMENTS:
  - gcloud (use '--help-gcloud-cli' for more details)
  - python3 (for comparing files)
  - git (for syncing with github repos)

INSTALLATION:
  Using '--install' option will create a folder ~/gcp2git and put the script inside.
  That path will be exported to ~/.bashrc so it can be used from anywhere.
  Script requires gcloud, python3 and git installed, so it will install those packages.
  Use '--install-y' to preapprove dependencies and run GCloud CLI login in the end..
  Using '--uninstall' will remove ~/gcp2git folder and ~/.bashrc inserts. 
  You can remove gcloud, python3 and git dependencies manually, if needed.

OPTIONS:
  gcp2git.sh [-v | --version] [-h | --help] [--help-actions] [--help-gcloud-cli] 
             [--install] [--install-y] [--uninstall] [--chk-install] [--chk-for-updates] 
             [--auto-chk-for-updates-off] [--auto-chk-for-updates-on] 
             [--generate-env-file] [--update-gitignore-file] 
             [--compare-lcl-and-pg] [--compare-lcl-and-int] [--compare-pg-and-int]
             [--download-pg] [--download-int] 
             [--update-lcl-from-pg] [--update-lcl-from-int] [--update-pg-from-lcl] 
             [--update-pg-from-int] [--update-gh-from-pg] [--update-gh-from-int] 
             [--update-all-from-int] [--ltl] [--tl] [--carrier-push] 
             [--carrier-pull] [--rating] [--dispatch] [--tracking] [--imaging] 
             [--scac=<carrier_scac>] <carrier_scac>

OPTIONS (details):
  general:
    -v | --version                Display script version and author.
    -h | --help                   Display help and usage info.
    --help-actions                Display available actions.
    --help-gcloud-cli             Display GCloud CLI help.
    --install                     Install script to use from anywhere in terminal.
    --install-y	                  Preapproves dependencies and runs 'gcloud auth login' after installation.
    --uninstall                   Remove changes made during install (except dependencies: gcloud, python3, git).
    --chk-install                 Check if script and requirements are installed correctly.
    --chk-for-updates             Check for new script versions.
    --auto-chk-for-updates-off    Turns off automatic check for updates (default value).
    --auto-chk-for-updates-on     Check for updates on every script execution (checks on every run).
    --generate-env-file           Generates '.env_gcp2git' in the current folder.
    --update-gitignore-file       Updates '.gitignore' file.

  actions:
    --compare-lcl-and-pg          Downloads playground files and compares content with local files.
    --compare-lcl-and-int         Downloads qa-int files and compares content with local files.
    --compare-pg-and-int          Downloads playground and qa-int files and compares content of each file.
    --download-pg                 Download remote playground files.
    --download-int                Download remote qa-int files.
    --update-lcl-from-pg          Updates local files from GCP playground.
    --update-lcl-from-int         Updates local files from GCP qa-int.
    --update-pg-from-lcl          Updates GCP playground files from local.
    --update-pg-from-int          Updates GCP playground files from GCP qa-int.
    --update-gh-from-pg           Updates GitHub files from GCP playground.
    --update-gh-from-int          Updates GitHub files from GCP qa-int.
    --update-all-from-int         Updates local, GCP playground, and GitHub files from GCP qa-int.

  interaction-modes:
    --ltl                         Set mode to 'LTL' (default value).
    --tl                          Set mode to 'TL'.
    --carrier-push                Set interaction to 'CARRIER_PUSH'.
    --carrier-pull                Set interaction to 'CARRIER_PULL' (default value).

  services:
    --rating                      Set service to 'RATING'.
    --dispatch                    Set service to 'DISPATCH'.
    --tracking                    Set service to 'SHIPMENT_STATUS'.
    --imaging                     Set service to 'IMAGING'.

  carrier:
    --scac=<carrier_scac>         Set carrier scac (case insensitive; can be set without using flags).

USAGE:
  gcp2git.sh abfs --imaging --compare-lcl-and-pg
  gcp2git.sh --tl --rating --download-pg gtjn
  gcp2git.sh --carrier-pull --dispatch --scac EXLA --update-lcl-from-int
  gcp2git.sh --tracking --scac gtjn --update-gh-from-pg

NOTES:
  - Tested on WSL Ubuntu 22.04
  - Default mode is 'LTL', default interaction is 'CARRIER_PULL'.
  - Carrier scac, service name and action are required.
  - Carrier can be specified without using '--scac' flag and is case insensitive.
  - Flags are prioritized over .env file values.
EOL
)

# Modes text
actions_text=$(cat <<EOL
ACTIONS:
  --compare-lcl-and-pg     Downloads playground files and compares content with local files.
  --compare-lcl-and-int    Downloads qa-int files and compares content with local files.
  --compare-pg-and-int     Downloads playground and qa-int files and compares content of each file.
  --download-pg            Download remote playground files.
  --download-int           Download remote qa-int files.
  --update-lcl-from-pg     Updates local files from GCP playground.
  --update-lcl-from-int    Updates local files from GCP qa-int.
  --update-pg-from-lcl     Updates GCP playground files from local.
  --update-pg-from-int     Updates GCP playground files from GCP qa-int.
  --update-gh-from-pg      Updates GitHub files from GCP playground.
  --update-gh-from-int     Updates GitHub files from GCP qa-int.
  --update-all-from-int    Updates local, GCP playground, and GitHub files from GCP qa-int.
EOL
)

# GCloud CLI help text
gcloud_cli_text=$(cat <<EOL
GCLOUD CLI INSTALLATION:

  For automatic installation, use '--install' or '--install-y' option.

  Official documentation:
  -----------------------
  - gsutil tool: https://cloud.google.com/storage/docs/gsutil
  - gsutil installation: https://cloud.google.com/sdk/docs/install
  - downloading files: https://cloud.google.com/storage/docs/downloading-objects#gcloud_1

  For Project44:
  --------------
  0) Install apt-transport-https:
     sudo apt install apt-transport-https ca-certificates gnupg curl

  1) Add the GCloud CLI distribution URI as a package source:
     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

  2) Import the Google Cloud public key:
     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

  3) Update and install the GCloud CLI:
     sudo apt update && sudo apt install google-cloud-cli

  - Login to GCloud CLI
    gcloud auth login my.email@project44.com

  - List connected accounts
    gcloud auth list
EOL
)


############################################################################################
###################################### Vars and flags ######################################
############################################################################################


# Initialize variables to default values
do_install=false
do_install_y=false
do_uninstall=false
do_chk_install_=false
# ref_chk_for_updates (do not change comment)
flg_chk_for_updates=false
flg_generate_env_file=false
flg_compare_lcl_and_pg=false
flg_compare_lcl_and_int=false
flg_compare_pg_and_int=false
flg_download_pg=false
flg_download_qa_int=false
flg_update_lcl_from_pg=false
flg_update_lcl_from_qa_int=false
flg_update_pg_from_lcl=false
flg_update_pg_from_qa_int=false
flg_update_gh_from_pg=false
flg_update_gh_from_qa_int=false
flg_update_all_from_qa_int=false

gcp_pg_base_url="gs://p44-datafeed-pipeline/qa-int/src"
gcp_qa_int_base_url="gs://p44-integration-us-central1-data-feed-plan-definitions-int/qa-int/src"
mode="LTL"
interaction="CARRIER_PULL"
service=""
carrier=""


# Load local .env_gcp2git file
if [ -e ".env_gcp2git" ]; then
	# echo "Loading values from local .env file."
	source .env_gcp2git

	# Set actions from .env

	# Load compare local and pg value
	if [ ! -z "$COMPARE_LCL_AND_PG" ]; then
		flg_compare_lcl_and_pg="$COMPARE_LCL_AND_PG"
	fi

	# Load compare local and int value
	if [ ! -z "$COMPARE_LCL_AND_INT" ]; then
		flg_compare_lcl_and_int="$COMPARE_LCL_AND_INT"
	fi

	# Load compare pg and int value
	if [ ! -z "$COMPARE_PG_AND_INT" ]; then
		flg_compare_pg_and_int="$COMPARE_PG_AND_INT"
	fi

	# Load download playground value
	if [ ! -z "$DOWNLOAD_PG" ]; then
		flg_download_pg="$DOWNLOAD_PG"
	fi

	# Load download qa int value
	if [ ! -z "$DOWNLOAD_QA_INT" ]; then
		flg_download_qa_int="$DOWNLOAD_QA_INT"
	fi

	# Load update local from playground value
	if [ ! -z "$UPDATE_LCL_FROM_PG" ]; then
		flg_update_lcl_from_pg="$UPDATE_LCL_FROM_PG"
	fi

	# Load update local from qa-int value
	if [ ! -z "$UPDATE_LCL_FROM_QA_INT" ]; then
		flg_update_lcl_from_qa_int="$UPDATE_LCL_FROM_QA_INT"
	fi

	# Load update playground from local value
	if [ ! -z "$UPDATE_PG_FROM_LCL" ]; then
		flg_update_pg_from_lcl="$UPDATE_PG_FROM_LCL"
	fi

	# Load update playground from qa-int value
	if [ ! -z "$UPDATE_PG_FROM_QA_INT" ]; then
		flg_update_pg_from_qa_int="$UPDATE_PG_FROM_QA_INT"
	fi

	# Load update github from playground value
	if [ ! -z "$UPDATE_GH_FROM_PG" ]; then
		flg_update_gh_from_pg="$UPDATE_GH_FROM_PG"
	fi

	# Load update github from qa-int value
	if [ ! -z "$UPDATE_GH_FROM_QA_INT" ]; then
		flg_update_gh_from_qa_int="$UPDATE_GH_FROM_QA_INT"
	fi

	# Load update all from qa-int value
	if [ ! -z "$UPDATE_ALL_FROM_QA_INT" ]; then
		flg_update_all_from_qa_int="$UPDATE_ALL_FROM_QA_INT"
	fi

	# Set URLs from .env

	# Load playground base URL value
	if [ ! -z "$PLAYGROUND_BASE_URL" ]; then
		playground_base_url="$PLAYGROUND_BASE_URL"
	fi

	# Load qa int base URL value
	if [ ! -z "$QA_INT_BASE_URL" ]; then
		qa_int_base_url="$QA_INT_BASE_URL"
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

while [ "$1" != "" ]; do
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
		--help-actions)
			echo "$actions_text"
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
		--compare-lcl-and-pg)
			flg_compare_lcl_and_pg=true
			;;
		--compare-lcl-and-int)
			flg_compare_lcl_and_int=true
			;;
		--compare-pg-and-int)
			flg_compare_pg_and_int=true
			;;
		--download-pg)
			flg_download_pg=true
			;;
		--download-int)
			flg_download_qa_int=true
			;;
		--update-lcl-from-pg)
			flg_update_lcl_from_pg=true
			;;
		--update-lcl-from-int)
			flg_update_lcl_from_qa_int=true
			;;
		--update-pg-from-lcl)
			flg_update_pg_from_lcl=true
			;;
		--update-pg-from-int)
			flg_update_pg_from_qa_int=true
			;;
		--update-gh-from-pg)
			flg_update_gh_from_pg=true
			;;
		--update-gh-from-int)
			flg_update_gh_from_qa_int=true
			;;
		--update-all-from-int)
			flg_update_all_from_qa_int=true
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
			;;
		*)
			carrier="${1^^}"
			;;
	esac
	shift
done

# Set local folder paths
local_pg_folder="./downloaded_playground_${mode}_${interaction}_${service}_${carrier}"
local_qa_int_folder="./downloaded_qa_int_${mode}_${interaction}_${service}_${carrier}"
gcp_pg_upload_dir_url="$gcp_pg_base_url/$mode/$service/$interaction"
gcp_pg_full_url="$gcp_pg_base_url/$mode/$service/$interaction/$carrier"
gcp_qa_int_full_url="$gcp_qa_int_base_url/$mode/$service/$interaction/$carrier"

# Set download freshness flags
flg_fresh_gcp_pg_download=false
flg_fresh_gcp_qa_int_download=false

# Echo variables (needs update)
# echo "source_folder=$source_folder"
# echo "destination_folder=$destination_folder"
# echo "flg_compare_pg_and_int=$flg_compare_pg_and_int"
# echo "flg_download_pg=$flg_download_pg"
# echo "flg_download_qa_int=$flg_download_qa_int"
# echo "update_git=$update_git"
# echo "update_pg=$update_pg"
# echo "update_local=$update_local"
# echo "update_all=$update_all"
# echo "playground_base_url=$playground_base_url"
# echo "qa_int_base_url=$qa_int_base_url"
# echo "mode=$mode"
# echo "interaction=$interaction"
# echo "service=$service"
# echo "carrier=$carrier"


################################################################################################
###################################### Requirement check functions #############################
################################################################################################


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

# Temp check
# Check if install/uninstall or action is set
# if [ "$flg_chk_for_updates" != "true" ] && [ "$do_install" != "true" ] &&  [ "$do_install_y" == "true" ] && [ "$do_uninstall" != "true" ] &&
# [ "$do_chk_install" != "true" ] && [ "$generate_env_file" == "true" ] && ["$flg_update_gitignore" == "true" ] &&
# [ "$flg_compare_lcl_and_pg" != "true" ] && [ "$flg_compare_lcl_and_int" != "true" ] && [ "$flg_compare_pg_and_int" != "true" ] &&
# [ "$flg_download_pg" != "true" ] && [ "$flg_download_qa_int" != "true" ] && [ "$flg_update_lcl_from_pg" != "true" ] &&
# [ "$flg_update_lcl_from_qa_int" != "true" ] && [ "$flg_update_pg_from_lcl" != "true" ] &&
# [ "$flg_update_pg_from_qa_int" != "true" ] && [ "$flg_update_gh_from_pg" != "true" ] &&
# [ "$flg_update_gh_from_qa_int" != "true" ] && [ "$flg_update_all_from_qa_int" != "true" ]; then
	# echo "Error: No action specified! Please use --help or --help-actions flag to see available actions."
	# exit 1
# fi


#################################################################################################
###################################### Install / Uninstall functions ############################
#################################################################################################


# Main installation function
install_script() {
	echo "Info: Installing gcp2git..."
	script_directory="$(dirname "$(readlink -f "$0")")"
	# Check if requirements installed
	if ! check_gcloud_installed || ! check_python_installed || ! check_git_installed; then
		install_requirements
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
	echo "Info: Setting up '~/gcp2git' directory..."
	mkdir ~/gcp2git
	mkdir ~/gcp2git/main
	mkdir ~/gcp2git/util
	cp $script_directory/gcp2git.sh ~/gcp2git/main
	# Generate autocomplete script
	generate_autocomplete_script
	echo "Info: Setting up '~/gcp2git' directory completed."
	# Set up bashrc inserts
	echo "Info: Adding paths to '~/.bashrc'..."
	echo "# gcp2git script" >> ~/.bashrc
	echo 'export PATH=$PATH:~/gcp2git/main' >> ~/.bashrc
	echo "source ~/gcp2git/util/gcp2git_autocomplete.sh" >> ~/.bashrc
	echo "Info: Paths added to '~/.bashrc'."
	# Print success message
	echo "Info: Success. Script installed in '~/gcp2git' folder."
	# If '--install-y' was used, set up gcloud auth
	if [ "$do_install_y" == "true" ]; then
		echo "Info: Setting up GCloud CLI login..."
		echo "Q: Input your p44 email:"
		read email
		gcloud auth login $email
		if gcloud auth list | grep -q "$email"; then
			echo "Info: Logged in to GCloud CLI."
		else
			echo "Error: Something went wrong during GCloud CLI login attempt."
		fi
	else
		echo "Info: Use 'gcloud auth login my.email@project44.com' to login to GCloud CLI."
		echo "Info: Use 'gcloud auth list' to check if you are logged in."
	fi
	echo "Info: Log in again to apply changes (if on wsl, do 'wsl --shutdown' and reopen in 10s)." 
	echo "Info: You can remove the current script file."
	echo "Info: Use '-h' or '--help' to get started."
	exit 0
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

install_requirements() {
	sudo apt update
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
	echo "Info: Script required gcloud, python3 and git installed. You can remove these packages manually if needed."
	echo "Info: Uninstall completed."
	exit 0
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
	options+="--help -h --help-gcloud-cli --help-actions --install --install-y --uninstall --chk-install --generate-env-file "
	options+="--update-gitignore-file --compare-lcl-and-pg --compare-lcl-and-int --compare-pg-and-int "
	options+="--download-pg --download-int --update-lcl-from-pg --update-lcl-from-int --update-pg-from-lcl "
	options+="--update-pg-from-int --update-gh-from-pg --update-gh-from-int --update-all-from-int "
	options+="--ltl --tl --carrier-push --carrier-pull --rating --dispatch --tracking --imaging --scac"

	COMPREPLY=(\$(compgen -W "\$options" -- "\$cur"))
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

# Fields can be overridden by flags

# ACTIONS
COMPARE_LCL_AND_PG=false
COMPARE_LCL_AND_INT=false
COMPARE_PG_AND_INT=false
DOWNLOAD_PG=false
DOWNLOAD_QA_INT=false
UPDATE_LCL_FROM_PG=false
UPDATE_LCL_FROM_QA_INT=false
UPDATE_PG_FROM_LCL=false
UPDATE_PG_FROM_QA_INT=false
UPDATE_GH_FROM_PG=false
UPDATE_GH_FROM_QA_INT=false
UPDATE_ALL_FROM_QA_INT=false

# URLS (defaults: already set)
PLAYGROUND_BASE_URL=""
QA_INT_BASE_URL=""

# INTEGRATION DETAILS (defaults: MODE=LTL, INTERACTION=CARRIER_PULL)
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

check_installation() {
	local cnt_missing=0
	if check_gcloud_installed; then
		echo "Info: GCloud CLI ------------- OK."
	else
		echo "Error: GCloud CLI ------------ NOT FOUND."
		((cnt_missing++))
	fi

	if check_python_installed; then
		echo "Info: Python ----------------- OK."
	else
		echo "Error: Python ---------------- NOT FOUND."
		((cnt_missing++))
	fi

	if check_git_installed; then
		echo "Info: Git -------------------- OK."
	else
		echo "Error: Git ------------------- NOT FOUND."
		((cnt_missing++))
	fi
		
	if [ -d ~/gcp2git ] && [ -f ~/gcp2git/main/gcp2git.sh ] && [ -f ~/gcp2git/util/gcp2git_autocomplete.sh ]; then
		echo "Info: Folder ~/.gcp2git ------ OK."
	else
		echo "Error: Folder ~/.gcp2git ----- NOT OK."
		((cnt_missing++))
	fi

	if grep -q "# gcp2git script" ~/.bashrc && grep -q 'export PATH=$PATH:~/gcp2git/main' ~/.bashrc &&
		grep -q "source ~/gcp2git/util/gcp2git_autocomplete.sh" ~/.bashrc; then
		echo "Info: File ~/.bashrc --------- OK."
	else
		echo "Error: File ~/.bashrc -------- NOT OK."
		((cnt_missing++))
	fi	

	if [ "$cnt_missing" -gt "0" ]; then
		echo "Error: Problems found. Use '--install' or '--install-y' to (re)install the script."
	fi
	exit 0
}


###########################################################################################
###################################### Version check ######################################
###########################################################################################


check_for_updates() {
	local local_version=$(echo "$version" | sed 's/^v//')
	local remote_version=$(curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | cat | grep "tag_name" | sed 's/.*"v\([0-9.]*\)".*/\1/' | cat)
	local version_result=$(awk -v v1="$local_version" -v v2="$remote_version" 'BEGIN {if (v1==v2) {result=0; exit;}; split(v1, a, "."); split(v2, b, "."); for (i=1; i<=length(a); i++) {if (a[i]<b[i]) {result=1; exit;}} {result=0; exit;}} END {print result}')
	case $version_result in
		0) echo "Info: You already have the latest script version ($version).";;
		1) echo "Info: New version available (v$remote_version). Please visit '$repo/releases' for more info.";;
	esac
}


###############################################################################################
###################################### Utility functions ######################################
###############################################################################################


check_args() {
        local required_number_of_args=$1
        shift;
        local total_number_of_args=$#
        local args=$@
        if [ $total_number_of_args -ne $required_number_of_args ]; then
        	echo "Error: Required $number_of_args arguments!"
        	exit 1
        fi
        for arg in $args; do
        	if [ -z "$arg" ]; then
                	echo "Error: Argument cannot be null or empty!"
			exit 1
        	fi
        done
}

# Generic function. Downloads files from GCP.
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

# Generic function. Uploads files to GCP.
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

# Generic function. Checks file content differences between two folders.
# $1 - source folder to iterate over
# $2 - target folder to search for files and check content
compare_files() {
	# Check arg count and npe, assign values
	check_args 2 $@
	local source_folder=$1
	local target_folder=$2
	# Function logic
	for source_file in "$source_folder"/*; do
		# Check if it's a file
		if [ -f "$source_file" ]; then
			# Extract the filename from the path
			filename=$(basename "$source_file")
			if check_file_prefix "$filename"; then
				target_folder_file_path="$target_folder/$filename"
				if cmp -s "$source_file" "$target_folder_file_path"; then
					:
				elif [[ "$source_file" == *.json ]] &&
					diff <(cat "$source_file" | python3 -m json.tool) <(cat "$target_folder_file_path" | python3 -m json.tool) &> /dev/null; then
					echo "Info: File '$source_file' has matching content, but different formatting."
				else
					echo "Info: File $filename doesn't have matching content"
					# If target file exists, print differences
					if [ -f "$target_folder_file_path" ]; then
						echo "Info: File content: $source_file"
						grep -nFxvf "$source_file" "$target_folder_file_path"
						echo "Info: File content: $target_folder_file_path"
						grep -nFxvf "$target_folder_file_path" "$source_file"
					fi
				fi
			fi
		fi
	done
}

# Generic function. Checks if a file starts with any of the prefixes.
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

# Generic function. Updates content of files using another folder as source.
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
				echo "Info: Destination file '$destination_path' does not exist. Skipping."
			# Update local files if flag set
			elif [ -e "$destination_path" ]; then
				# Copy the content of the source file to the destination file
				cat "$source_file" > "$destination_path"
				echo "Info: Copied content of '$source_file' to '$destination_path'"
			else
				:
			fi
		fi
	done
}

# Generic function. Update local files from source folder.
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

# Generic function. Uploads files to GCP playground.
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
	upload_file_to_gcp "$tmp_dir/$carrier" "$gcp_pg_upload_dir_url"
	echo "Info: Uploaded files to GCP playground"
	rm -rf "$tmp_dir"
}

# Generic function. Check if git installed.
check_is_git_repo() {
	# Check if directory is a git repo
	if [ -d ".git" ] && [ "$(git rev-parse --is-inside-work-tree)" == "true" ]; then
   		return 0
   	else
		return 1
	fi
}

# Generic function. Check if git installed.
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

# Generic function. Update .gitignore file.
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

# Generic function. Commit git changes.
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
	if [ "${push_changes,,}" == "y" ] ||  [ -z $push_changes ]; then
		git push origin "$(git branch --show-current)"
	else
		:
	fi
}


###################################################################################################
###################################### Implemented functions ######################################
###################################################################################################


# Compare local and playground files
compare_lcl_and_pg() {
	download_from_pg
	compare_files "." $local_pg_folder
}

# Compare local and qa-int files
compare_lcl_and_qa_int() {
	download_from_qa_int
	compare_files "." $local_qa_int_folder
}

# Compare playground and qa-int files
compare_pg_and_qa_int() {
	download_from_pg
	download_from_qa_int
	compare_files $local_pg_folder $local_qa_int_folder
}

# Download files from GCP playground
download_from_pg() {
	echo "Info: Downloading GCP playground files."
	if [ -d "$local_pg_folder" ] && [ "$flg_fresh_gcp_pg_download" != "true" ]; then
		rm -r "$local_pg_folder"
		mkdir "$local_pg_folder"
		download_from_gcp "$gcp_pg_full_url/*" "$local_pg_folder"
	else
		mkdir "$local_pg_folder"
		download_from_gcp "$gcp_pg_full_url/*" "$local_pg_folder"
	fi
	flg_fresh_gcp_pg_download=true
}

# Download files from GCP qa-int
download_from_qa_int() {
	echo "Info: Downloading GCP qa-int files."
	if [ -d "$local_qa_int_folder" ] && [ "$flg_fresh_gcp_pg_download" != "true" ]; then
		rm -r "$local_qa_int_folder"
		mkdir "$local_qa_int_folder"
		download_from_gcp "$gcp_qa_int_full_url/*" "$local_qa_int_folder"
	else
		mkdir "$local_qa_int_folder"
		download_from_gcp "$gcp_qa_int_full_url/*" "$local_qa_int_folder"
	fi
	flg_fresh_gcp_qa_int_download=true
}

# Update local files from GCP playground
update_local_from_pg() {
	download_from_pg
	update_local_from_source "$local_pg_folder"
}

# Update local files from GCP qa-int
update_local_from_qa_int() {
	download_from_qa_int
	update_local_from_source "$local_qa_int_folder"
}

# Update GCP playground files from local
update_pg_from_local() {
	upload_to_pg "."
}

# Update GCP playground files from GCP qa-int
update_pg_from_qa_int() {
	download_from_qa_int
	upload_to_pg "$local_qa_int_folder"
}

# Update GitHub files from GCP playground
update_github_from_pg() {
	download_from_pg
	update_local_from_source "$local_pg_folder"
	update_github
}

# Update GitHub files from GCP qa-int
update_github_from_qa_int() {
	download_from_qa_int
	update_local_from_source "$local_qa_int_folder"
	update_github
}

# Update local, GitHub and GCP playground files from GCP qa-int
update_all_from_qa_int() {
	download_from_qa_int
	upload_to_pg "$local_qa_int_folder"
	update_local_from_source "$local_qa_int_folder"
	update_git_from_qa_int
}

# Updates/creates .gitignore file and commits changes
update_github() {
	update_gitignore
	commit_git
}


###############################################################################################################
############################################ Action requirements check  #######################################
###############################################################################################################


check_action_requirements() {
	if ! check_gcloud_installed; then
		echo "Info: GCloud CLI is not installed. It is required for GCP access."
	fi

	if ! check_python_installed; then
		echo "Info: Python is not installed. Comparing files may not work properly."
	fi

	if ! check_git_installed; then
		echo "Info: Git is not installed. Syncing with GitHub may not work properly."
	fi

	# Check if carrier scac is provided
	check_carrier() {
		if [ -z "$carrier" ]; then
			echo "Error: No carrier scac provided!"
			exit 1
		fi
	}

	# Check if service name is provided
	check_service() {
		if [ -z "$service" ]; then
			echo "Error: No service name provided!"
			exit 1
		fi
	}
}


###########################################################################################################################
############################################ Flags checks and function calls ##############################################
###########################################################################################################################


# General

# Check for updates
if [ "$flg_chk_for_updates" == "true" ]; then
	check_for_updates
fi

# Install
if [ "$do_install" == "true" ] || [ "$do_install_y" == "true" ]; then
	install_script
fi

# Uninstall
if [ "$do_uninstall" == "true" ]; then
	uninstall_script
fi

# Install GCloud CLI
if [ "$do_chk_install" == "true" ]; then
	check_installation
fi

# Generate env file
if [ "$flg_generate_env_file" == "true" ]; then
	generate_env_file
fi

# Action calls

check_action_requirements

# Compare local and playground
if [ "$flg_compare_lcl_and_pg" == "true" ]; then
	compare_lcl_and_pg
fi

# Compare local and qa-int
if [ "$flg_compare_lcl_and_int" == "true" ]; then
	compare_lcl_and_qa_int
fi

# Compare playground and qa-int
if [ "$flg_compare_pg_and_int" == "true" ]; then
	compare_pg_and_qa_int
fi

# Download from GCP playground
if [ "$flg_download_pg" == "true" ]; then
	download_from_pg
fi

# Download from GCP qa-int
if [ "$flg_download_qa_int" == "true" ]; then
	download_from_qa_int
fi

if [ "$flg_update_lcl_from_pg" == "true" ]; then
	update_local_from_pg
fi

if [ "$flg_update_lcl_from_qa_int" == "true" ]; then
	update_local_from_qa_int
fi

if [ "$flg_update_pg_from_lcl" == "true" ]; then
	update_pg_from_local
fi

if [ "$flg_update_pg_from_qa_int" == "true" ]; then
	update_pg_from_qa_int
fi

if [ "$flg_update_gh_from_pg" == "true" ]; then
	update_github_from_pg
fi

if [ "$flg_update_gh_from_qa_int" == "true" ]; then
	update_github_from_qa_int
fi

if [ "$flg_update_gitignore" == "true" ]; then
	update_gitignore
fi


###################################################################################################
############################################ Cleanup ##############################################
###################################################################################################


if [ "$flg_download_pg" != "true" ] && [ -d "$local_pg_folder" ]; then
	rm -r "$local_pg_folder"
fi

if [ "$flg_download_qa_int" != "true" ] && [ -d "$local_qa_int_folder" ]; then
	rm -r "$local_qa_int_folder"
fi

echo "Info: Script completed."
