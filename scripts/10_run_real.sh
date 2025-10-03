# #!/bin/bash

# In order to set up X11 forwarding, you need to tell the X server
# to allow local apps (like docker) to connect
xhost +local:docker

rocker \
  --env PROJECT_ENV=real \
  --devices /dev/dri \
  --nvidia --cuda \
  --ssh --x11 \
  --network host \
  --pulse \
  --git \
  --privileged \
  --mode interactive \
  --nocleanup \
  --persist-image \
  turtlebot3_humble:local /bin/bash

