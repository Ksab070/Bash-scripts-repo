#!/bin/bash
set -euo pipefail 
# -e : causes the script to exit in case of any command fails.
# -u : treats unset variables as an error and exit the script
# -o : ensures that a pipeline fails if any command in the pipe fails 


check_dependencies() {
    if ! command -v aws  &> /dev/null; then 
        echo "AWS CLI not installed, installing AWSCLI" >&2 
        return 1 
    fi
}

install_dependencies() {
     if ! command -v python &> /dev/null then
        echo "Python not installed, required for AWSCLI installation" >&2
        yum install python
    fi
    echo 
}