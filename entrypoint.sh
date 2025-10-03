#!/bin/bash
# Make sure to abort immediately if any command fails
set -e

# Setup ROS workspace with Colcon argument completion
source /opt/ros/humble/setup.bash
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash

# Setup Gazebo Classic (Ignition works out-of-the-box)
source /usr/share/gazebo/setup.sh

# Setup local workspace
source ${ROS_WS}/install/setup.bash

# Change directory to workspace source
cd ${ROS_WS}/src/

# Add the Gazebo model path from the turtlebot3_simulations repo to ensure Gazebo model loading works correctly
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:${ROS_WS}/src/turtlebot3_simulations/turtlebot3_gazebo/models/

# Set environment variables based on project environment
if [ "$PROJECT_ENV" == "real" ]; then
  export ROS_DOMAIN_ID=141
  export TURTLEBOT3_MODEL=burger
elif [ "$PROJECT_ENV" == "sim" ]; then
  export ROS_DOMAIN_ID=1
  export TURTLEBOT3_MODEL=burger
else
  export ROS_DOMAIN_ID=0
  export TURTLEBOT3_MODEL=burger
fi

# If no arguments are specified, run a new bash session by default
if [ $# -eq 0 ]; then
  exec /bin/bash
else
  exec "$@"
fi
