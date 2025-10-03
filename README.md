# turtlebot3-docker-demo
Testing the Turtlebot3 demos (real &amp; simulated) with Docker &amp; GPU integration.

* [Setup](#setup)
  * [Prerequisites](#prerequisites)
  * [Install docker](#install-docker)
    * [Installation](#installation-source)
    * [Verification](#verification)
    * [Post-installation](#post-installation-source)
    * [(Optional) Launch Docker on boot](#optional-launch-docker-on-boot)
  * [(Optional) Enable NVIDIA GPU support](#optional-enable-nvidia-gpu-support)
    * [Install/Update NVIDIA CUDA Driver](#installupdate-nvidia-cuda-driver-source)
    * [Installat NVIDIA Container Toolkit](#installat-nvidia-container-toolkit-source)
* [Install Rocker](#install-rocker)
  * [Minimal Setup](#minimal-setup-source)
  * [Install Rocker](#install-rocker-1)
* [Usage](#usage)

## Setup

### Prerequisites

* OS: Ubuntu Noble 24.04 (LTS) or Ubuntu Jammy 22.04 (LTS)
  * NOTE: Any Ubuntu-like flavor like Linux Mint works. Use `inxi -Sx` to verify what base image you have.

All steps below have been copied from their respective source guides. If anything breaks, check the sources for any changes.

### Install docker

#### Installation [[source](https://docs.docker.com/engine/install/ubuntu/#uninstall-old-versions)]

```bash
# Uninstall any conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Refresh list of installable packages
sudo apt-get update

# Install latest version of docker engine
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```

#### Verification
```bash
# Verify that the docker service is running
sudo systemctl status docker

# If not, start the service
sudo systemctl start docker

# Verify that docker is running
sudo docker run hello-world
```

#### Post-installation [[source](https://docs.docker.com/engine/install/linux-postinstall/)]
This enables using docker without `sudo`, although it'll enable root-level permissions for your user.
```bash
# Create a new group and add your user to it
sudo groupadd docker
sudo usermod -aG docker $USER

# Activate the group changes
newgrp docker

# Verify that you can run docker without 'sudo'
docker run hello-world
```

If you see the following error with `docker run`:
```bash
WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied
```

You'll need to change the permission settings for `~/.docker/` as follows:
```bash
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
```

#### (Optional) Launch Docker on boot
This ensures that the docker service will always be active when logging in.
```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

This can be disabled later on.
```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

### (Optional) Enable NVIDIA GPU support

#### Install/Update NVIDIA CUDA Driver [[source](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/)]
```bash
# Verify the NVIDIA CUDA driver is installed
nvidia-smi
```

Example output:
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.65.06              Driver Version: 580.65.06      CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA RTX A3000 12GB La...    Off |   00000000:01:00.0  On |                  Off |
| N/A   48C    P3             24W /   80W |    1942MiB /  12288MiB |     12%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
```

If this doesn't work, this can be fixed by installing the proper NVIDIA CUDA driver. Otherwise go to the next section.

```bash
# Show the list of recommended
sudo ubuntu-drivers list --recommended

# If nothing shows, run it again command without '--recommended' & select the latest version
sudo ubuntu-drivers list
```

Example output:
```bash
nvidia-driver-580-open, (kernel modules provided by linux-modules-nvidia-580-open-generic)
nvidia-driver-570-open, (kernel modules provided by linux-modules-nvidia-570-open-generic)
nvidia-driver-550, (kernel modules provided by linux-modules-nvidia-550-generic)
nvidia-driver-535, (kernel modules provided by linux-modules-nvidia-535-generic)
nvidia-driver-580, (kernel modules provided by linux-modules-nvidia-580-generic)
nvidia-driver-570, (kernel modules provided by linux-modules-nvidia-570-generic)
nvidia-driver-535-server, (kernel modules provided by linux-modules-nvidia-535-server-generic)
nvidia-driver-580-server-open, (kernel modules provided by linux-modules-nvidia-580-server-open-generic)
nvidia-driver-570-server-open, (kernel modules provided by linux-modules-nvidia-570-server-open-generic)
nvidia-driver-550-open, (kernel modules provided by linux-modules-nvidia-550-open-generic)
nvidia-driver-535-open, (kernel modules provided by linux-modules-nvidia-535-open-generic)
nvidia-driver-580-server, (kernel modules provided by linux-modules-nvidia-580-server-generic)
nvidia-driver-570-server, (kernel modules provided by linux-modules-nvidia-570-server-generic)
nvidia-driver-535-server-open, (kernel modules provided by linux-modules-nvidia-535-server-open-generic)
```

Install the driver of choice as follows:
```bash
# Generic driver install command, replace XXX with the 3-digit number from above
sudo ubuntu-drivers install nvidia:XXX

# Example: Installing CUDA driver version 580
sudo ubuntu-drivers install nvidia:580
```

#### Installat NVIDIA Container Toolkit [[source](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)]
```bash
# Add repository to apt sources
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \ sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Refresh list of installable packages
sudo apt-get update

# Install the NVIDIA container toolkit
sudo apt-get install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1

# Enable the NVIDIA Container Runtime within Docker
sudo nvidia-ctk runtime configure --runtime=docker

# Restart the Docker service
sudo systemctl restart docker
```

## Install Rocker

If you have ROS1 or ROS2 installed, you should be able to install rocker with `sudo apt-get install python3-rocker`. Otherwise follow the instructions below.

### Minimal Setup [[source](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html)]
```bash
# Add the Ubuntu Universe repository
sudo apt install software-properties-common
sudo add-apt-repository universe

# Add repository to apt sources
sudo apt update && sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# Refresh list of installable packages
sudo apt update
```

### Install Rocker
```bash
sudo apt-get install python3-rocker
```

## Usage
1. Ensure that your Physical PC and Turtlebot are connected to the same network and have the same `ROS_DOMAIN_ID`
  * You can change the environment variables in `entrypoint.sh`.

2. SSH into the Turtlebot and launch the bring up command:
```bash
ros2 launch turtlebot3_bringup robot.launch.py
```

3. On your physical PC, start a new terminal. Run the following commands:
```bash
# Build the docker image
./scripts/00_build.sh

# Run a new docker container for operating a real Turtlebot3
# Launches the container using the host networking driver
./scripts/10_run_real.sh

# Run a new docker container for operating a simulated Turtlebot3
# Launches the container using the bridge networking driver
./scripts/11_run_sim.sh
```
You should be in the docker container ready to work with the Turtlebot. Your prefix username should change to `root`.

4. Within your container, run any of the Turtlebot3 ROS launch commands.
  * Teleoperation: `ros2 run turtlebot3_teleop teleop_keyboard`
  * Cartographer: `ros2 launch turtlebot3_cartographer cartographer.launch.py`
  * Navigation: `ros2 launch turtlebot3_navigation2 navigation2.launch.py map:=$HOME/map.yaml`
  * Gazebo Test: `ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py`
  * Camera View (V4L2): `ros2 run v4l2_camera v4l2_camera_node`
