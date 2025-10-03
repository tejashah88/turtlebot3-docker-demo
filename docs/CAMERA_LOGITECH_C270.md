The Logitech C270 has some quirks with defaults in parameters that have to be set properly in order for the 'v4l2_camera_node' to not crash.

## Setup instructions (on Turtlebot)
```bash
# Install packages
sudo apt-get install ros-humble-v4l2-camera raspi-config ros-humble-image-transport-plugins v4l-utils

# Raspi Config
sudo raspi-config
# Interface Options > Legacy Camera > Enable

# Enable the Legacy Camera Stack in the firmware
sudo nano /boot/firmware/config.txt
# Add the following lines:
# Disable libcamera auto detect
#   camera_auto_detect=0
# Enable legacy camera stack for bcm2835-v4l2
#   start_x=1

# Reboot the Raspberry Pi
sudo reboot

# Check the list of detected cameras
v4l2-ctl --list-devices

# Check the list of parameters for a specific device
v4l2-ctl --device=/dev/video0 --all

# Run the camera node with defaults for C270. Change as necessary based on parameter list
ros2 run v4l2_camera v4l2_camera_node \
  --ros-args \
  -p use_v4l2_controls:=false \
  -p brightness:=128 \
  -p contrast:=32 \
  -p saturation:=32 \
  -p gain:=0 \
  -p auto_exposure:=3 \
  -p white_balance_temperature:=4000 \
  -p sharpness:=24 \
  -p backlight_compensation:=1
```
