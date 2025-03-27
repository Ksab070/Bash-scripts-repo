#!/bin/bash

set -euo pipefail 
# -e : causes the script to exit in case of any command fails.
# -u : treats unset variables as an error and exit the script
# -o : ensures that a pipeline fails if any command in the pipe fails 


check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        echo "Python not installed, required for AWSCLI installation, installing python"
        if yum install python; then 
            echo "Python successfully installed: $(python -V)"
            else echo "Python installation failed"
        fi
        else echo "Python already installed: $(python -V)"
    fi

    if ! command -v aws  &> /dev/null; 
        then 
        echo "AWS CLI not installed, installing AWS CLI" >&2 
        install_awscli #AWS CLI function called 
        else echo "AWS CLI already installed: $(aws --verion)"
    fi
}

install_awscli() {
    echo "Installing AWS CLI"

    #Download aws-cli package
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

    #Check if unzip is available, if not -> install it
    if ! command -v unzip; then yum install unzip &> /dev/null
    fi 

    #Unzip aws-cli package, use -q for quiet extraction (Won't print output diretly on screen)
    unzip -q awscliv2.zip

    #Run the installation script
    ./aws/install

    echo "Installation successful: $(aws --version)"

    #Cleanup
    rm -rf awscliv2.zip ./aws
}

configure_awscli() {
    read -rp "Enter your Access key ID : " key_id 
    read -rsp "Enter your Secret Access key : " secret_key_id
    echo

    # read flags : -r -> prevents backslash from being treated as escape characters
    # -p -> Prompts us, thus no need for echo
    # -s -> Sensitive text, will not be visible while typing
    # echo after read -rsp -> Ensures a new line is printed after entering the secret key (otherwise, the next prompt appears on the same line).

    if [[ -z "$key_id" || -z "$secret_key_id" ]];
    # -z "$key_id" || -z "$secret_key_id" 
    # The above checks if any of the inputs are empty, if empty exit the function post giving an error 
    then 
    echo "Error : All inputs are required for configuration" >&2
    return 1 #Exit the function if error 
    fi  

    export AWS_ACCESS_KEY_ID=$key_id
    export AWS_SECRET_ACCESS_KEY=$secret_key_id
    #Hard coding the aws region, as AMI also depends on the region
    export AWS_DEFAULT_REGION="us-east-1"

    echo "AWS CLI configured successfully"
}

wait_for_instance() {
    local instance_id="$1"
    echo "Waiting for instance $instance_id to be in running state..."

    while true; do
        state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
        if [[ "$state" == "running" ]]; then
            echo "Instance $instance_id is now running."
            break
        fi
        sleep 10
    done
}

create_instance() {
    #Creating local variables, we will get this from the main function
    local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"

    # Run AWS CLI command to create EC2 instance
    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --subnet-id "$subnet_id" \
        --security-group-ids "$security_group_ids" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    if [[ -z "$instance_id" ]]; then 
    #If instance id is empty
        echo "Failed to create EC2 instance." >&2
        exit 1
    fi

    echo "Instance $instance_id created successfully."

    # Wait for the instance to be in running state
    wait_for_instance "$instance_id"
}


main() {
    check_dependencies && configure_awscli

    echo "Creating EC2 instance" 

    #Creating variables to call the create instance function to pass inputs
    AMI_ID="ami-08b5b3a93ed654d19" #AMI of amazon linux 2023 in us-east-1
    INSTANCE_TYPE="t3.medium"
    KEY_NAME="test"
    SUBNET_ID=""
    SECURITY_GROUP_IDS=""  # Add your security group IDs separated by space
    INSTANCE_NAME="Shell-Script-EC2"

    create_instance "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME" 

    echo "Instance creation complete" 
}

main "$@" 
#"$@" is a special Bash variable that represents all the positional parameters passed to the script. This means any arguments given to the script when it's executed will be forwarded to the main function.
# suppose if i give parameters like this 

#./some-script.sh ami-123123123 admin ksub 12 

#It will be treated as 

#$1 = "ami-123123123"
#$2 =  "admin" 
#$3 = "ksub"
#$4 = "12"





