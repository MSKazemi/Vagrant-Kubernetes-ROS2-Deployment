#!/usr/bin/env bash
# Run inside the built ROS 2 Jazzy container; no Kubernetes cluster needed.
# Usage: docker run --rm -i ros-jazzy-lab:local bash -s < scripts/test-ros2-image.sh
# ROS setup scripts rely on optional environment variables. Source before nounset.
set -eo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ "${ROS_DISTRO:-}" == "jazzy" ]] || fail "ROS_DISTRO must be jazzy (got ${ROS_DISTRO:-unset})"
# shellcheck disable=SC1091
source /opt/ros/jazzy/setup.bash
set -u
# The image must remain based on the tested Ubuntu 24.04 platform.
# shellcheck disable=SC1091
source /etc/os-release
[[ "${VERSION_ID:-}" == "24.04" ]] || fail "expected Ubuntu 24.04 (got ${VERSION_ID:-unknown})"

command -v ros2 >/dev/null || fail "ros2 command not found"
command -v stress-ng >/dev/null || fail "stress-ng command not found"
executables="$(ros2 pkg executables demo_nodes_cpp)"
grep -Eq '^demo_nodes_cpp[[:space:]]+talker$' <<< "$executables" || fail "C++ talker is missing"
grep -Eq '^demo_nodes_cpp[[:space:]]+listener$' <<< "$executables" || fail "C++ listener is missing"
stress-ng --version
# Bounded CPU exercise confirms stress-ng can execute, not just print its version.
stress-ng --cpu 1 --cpu-load 25 --timeout 2s --quiet
printf 'PASS: ROS 2 Jazzy, Ubuntu 24.04, demo_nodes_cpp and stress-ng are runnable.\n'

export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-42}"
export RCUTILS_LOGGING_BUFFERED_STREAM=0
tmpdir="$(mktemp -d)"
listener_pid=""
talker_pid=""

cleanup() {
  if [[ -n "$talker_pid" ]]; then kill "$talker_pid" 2>/dev/null || true; fi
  if [[ -n "$listener_pid" ]]; then kill "$listener_pid" 2>/dev/null || true; fi
  if [[ -n "$talker_pid" ]]; then wait "$talker_pid" 2>/dev/null || true; fi
  if [[ -n "$listener_pid" ]]; then wait "$listener_pid" 2>/dev/null || true; fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT

# An image smoke test, not a Kubernetes/DDS cross-worker integration test.
ros2 run demo_nodes_cpp listener > "$tmpdir/listener.log" 2>&1 &
listener_pid=$!
ros2 run demo_nodes_cpp talker > "$tmpdir/talker.log" 2>&1 &
talker_pid=$!

for ((attempt=1; attempt<=45; attempt++)); do
  if grep -Fq 'I heard:' "$tmpdir/listener.log"; then
    printf 'PASS: listener received a ROS 2 talker message inside one container.\n'
    grep -Fm1 'I heard:' "$tmpdir/listener.log"
    exit 0
  fi
  if ! kill -0 "$listener_pid" 2>/dev/null || ! kill -0 "$talker_pid" 2>/dev/null; then
    printf 'A ROS 2 demo process exited before the listener received a message.\n' >&2
    break
  fi
  sleep 1
done

printf 'FAIL: no ROS 2 message received within 45 seconds.\n' >&2
printf '%s\n' '--- talker log ---' >&2
cat "$tmpdir/talker.log" >&2 || true
printf '%s\n' '--- listener log ---' >&2
cat "$tmpdir/listener.log" >&2 || true
exit 1
