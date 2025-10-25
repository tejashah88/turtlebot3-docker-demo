FROM osrf/ros:humble-desktop-full-jammy

# Use /bin/bash over /bin/sh for ROS workspace initialization
# Source: https://stackoverflow.com/a/25423366
SHELL ["/bin/bash", "-c"]

# Assume defaults when encountering prompts during setup
ENV DEBIAN_FRONTEND=noninteractive

# User constants
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Add new non-root user
# Source: https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    # Add sudo support
    apt-get update && \
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Prepare for use with non-root user
USER $USERNAME
ENV HOME=/home/${USERNAME}

# Install common utilities
RUN sudo apt-get update && \
    sudo apt-get install -y \
        software-properties-common && \
    sudo rm -rf /var/lib/apt/lists/*

# Install additional dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y \
        # Install nano editor
        nano \
        # Install Gazebo Classic ROS packages & Turtlebot3 packages
        ros-humble-gazebo-ros-pkgs \
        # Install colcon extension dependencies
        python3-colcon-common-extensions \
        # Install Cartographer
        ros-humble-cartographer \
        ros-humble-cartographer-ros \
        # Install Navigation2
        ros-humble-navigation2 \
        ros-humble-nav2-bringup && \
    sudo rm -rf /var/lib/apt/lists/*

# Setup workspace
ENV ROS_WS=${HOME}/turtlebot3_ws
RUN mkdir -p ${ROS_WS}/src
WORKDIR ${ROS_WS}/src

# Clone Turtlebot3 packages
RUN git clone -b humble https://github.com/ROBOTIS-GIT/DynamixelSDK.git
RUN git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
RUN git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3.git
RUN git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
RUN git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_machine_learning.git
RUN git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_applications.git
RUN git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_applications_msgs.git

# Build Colcon workspace
WORKDIR ${ROS_WS}
RUN source /opt/ros/humble/setup.bash && \
  colcon build --symlink-install

# Entrypoint
COPY --chmod=0755 entrypoint.sh ${HOME}/entrypoint.sh
ENTRYPOINT ${HOME}/entrypoint.sh

# Interactive bash shell
CMD ["/bin/bash"]
