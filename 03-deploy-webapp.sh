#!/bin/bash

<<Task
Deploy a Django webapp and handle the error codes
Task

clone_repo() {
    if test -d "./django-notes-app"; 
    then echo "Directory already exists"
    echo "............................"
    else
    echo "Cloning the git repo........"
    echo "............................"
    git clone https://github.com/LondheShubham153/django-notes-app.git
    echo "Repository cloned successfully at $(pwd)"
    fi
    chmod 755 -R django-notes-app/
    cd ./django-notes-app
}

install_dependencies() {
    echo "Checking if dependencies are installed"
    echo "............................"
    echo "Checking for docker" 
    if docker --version &> /dev/null
    then echo "Docker is installed: $(docker --version)"

    else 
    dnf -y install dnf-plugins-core \
    && dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo \
    && dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && echo "Docker installed successfully $(docker --version)"
    fi

    echo "............................"
    echo "Checking for Nginx" 
    if nginx -v &> /dev/null
    then echo "Nginx is installed: $(nginx -v 2>&1)"

    else echo "Nginx not installed, installing nginx"
    yum install nginx -y
    echo "Nginx installed successfully $(nginx -v)"
    fi
}

start_services() {
    systemctl restart docker.service
    systemctl restart nginx
}

build_container() {
    echo "CMD python /app/backend/manage.py runserver 0.0.0.0:8000" >> Dockerfile
    docker build -t notes-app .
    docker run -d -p 8000:8000 notes-app:latest 
}

clone_repo
install_dependencies
start_services
build_container