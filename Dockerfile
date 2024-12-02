# stage 1
FROM nvidia/cuda:11.7.1-devel-ubuntu20.04 as build

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC && \
    apt update && apt install -y --no-install-recommends curl && \
    curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | apt-key add - && \
    apt install -y --no-install-recommends \
    cmake libvdpau-dev && \
    rm -rf /var/lib/apt/lists/*

COPY ./ /build/

RUN cd /build/ && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make -j $(nproc)

FROM alpine:3.14

WORKDIR /build/
COPY --from=build /build/libcuda-control.so /usr/lib/cuda/libcuda-control.so
COPY --from=build /build/nvml-monitor /usr/lib/cuda/bin/nvml-monitor