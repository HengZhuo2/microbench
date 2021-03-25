# Set this to point to the top level of the TailBench data directory
DATA_ROOT=/home/zohan/tailbench/data

# Set this to point to the top level installation directory of the Java
# Development Kit. Only needed for Specjbb
if [ $(uname -m) == "aarch64"];
then
    JDK_PATH=/usr/lib/jvm/java-1.11.0-openjdk-arm64
else
    JDK_PATH=/usr/lib/jvm/java-1.11.0-openjdk-amd64
fi

# This location is used by applications to store scratch data during execution.
SCRATCH_DIR=/tailbench/scratch
