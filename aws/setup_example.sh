#!/usr/bin/env bash

# script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# source $script_dir/aws.env

server_home_dir=/home/ubuntu
project_dir_name=app
model_file_download_url=https://huggingface.co/bartowski/Phi-3.1-mini-4k-instruct-GGUF/resolve/main/Phi-3.1-mini-4k-instruct-Q6_K_L.gguf
project_dir_path="$server_home_dir/$project_dir_name"
ubuntu_version="ubuntu2404/x86_64"
DOCKER_CONFIG=/usr/local/lib/docker

echo
echo "Installing Required Packages"
echo
sudo apt-get update
sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common

echo
echo "Installing Docker"
echo
# This is techinally the distro package, not official
sudo apt-get install -y docker.io

echo
echo "Installing Docker Compose"
echo
# https://docs.docker.com/compose/install/linux/
sudo mkdir -p $DOCKER_CONFIG/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo
echo "Installing Ubuntu Drivers Tool"
echo
# https://ubuntu.com/server/docs/nvidia-drivers-installation
sudo apt-get install -y ubuntu-drivers-common

echo
echo "Installing NVIDIA CUDA Toolkit"
echo
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
# Install Linux kernel headers
sudo apt-get install -y linux-headers-$(uname -r)

# Remove old NVIDIA repo key
sudo apt-key del 7fa2af80 || true  # Ignore errors if the key doesn't exist

# Download and install CUDA keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/$ubuntu_version/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# Install NVIDIA CUDA Toolkit
sudo apt-get update
sudo apt-get install -y nvidia-cuda-toolkit

echo
echo "Installing NVIDIA Container Toolkit"
echo
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker
sudo systemctl restart docker

echo
echo "Setting Virtual Memory Map (for OpenSearch)"
echo
# https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo
echo "Installing make and c++ compiler"
echo
sudo apt-get install -y make g++

echo
echo "Rebooting"
echo
sudo reboot

echo
echo "Installing NVIDIA Drivers"
echo
# Latest drivers didn't work, need to use a slightly older version of drivers
sudo ubuntu-drivers install nvidia:550

echo
echo "Rebooting"
echo
sudo reboot

echo
echo "Creating Project Directories"
echo
mkdir -p $project_dir_path
mkdir -p $project_dir_path/models

echo
echo "Downloading LLM Model File"
echo
cd $project_dir_path/models
curl -O -L $model_file_download_url

# Test NVIDIA container
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
