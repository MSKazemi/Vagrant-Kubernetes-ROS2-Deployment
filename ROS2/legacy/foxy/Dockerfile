# Historical reference only: ROS 2 Foxy reached end of life in June 2023.
# Reproduces the repository's original image recipe for legacy manifests.
# Do not use as a default for new development or production deployments.
FROM docker.io/osrf/ros:foxy-desktop

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends stress-ng && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["bash"]
