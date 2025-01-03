# Use the ROS2 Foxy desktop image as the base
FROM docker.io/osrf/ros:foxy-desktop

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install stress-ng
RUN apt-get update && \
    apt-get install -y --no-install-recommends stress-ng && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the default command to start a bash shell
CMD ["bash"]

