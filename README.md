# gcp2git

INFO:
-----
    author: Filip Vujic
    github: https://github.com/filipvujic-p44/gcp2git

    This script is a tool for easier downloading, syncing and comparing local, remote GitHub and GCP files.

REQUIREMENTS:
-------------
    - gcloud (for GCP access)
    - python3 (for comparing files)
    - git (for syncing with github repos)
    - bash-completion (for autocomplete)

INSTALLATION:
-------------
    Using '--install' option will create a folder ~/gcp2git and put the script inside.
    That path will be exported to ~/.bashrc so it can be used from anywhere.
    Script requires gcloud, python3, git and bash-completion, so it will install those packages.
    Use '--install-y' to preapprove dependencies and run GCloud CLI login after installation.
    Using '--uninstall' will remove ~/gcp2git folder and ~/.bashrc inserts. 
    You can remove gcloud, python3, git and bash-completion dependencies manually, if needed.
