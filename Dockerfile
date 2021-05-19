FROM nvidia/cuda:11.3.0-devel-ubuntu20.04
LABEL maintainer "viotemp1"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  wget \
  g++ \
  git \
  curl \
  software-properties-common

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Bucharest  apt-get install -y \
  libboost-date-time-dev libboost-filesystem-dev libboost-thread-dev \
  libboost-system-dev libboost-log-dev

RUN apt --fix-broken -y install
RUN apt-get upgrade -y

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs:${LIBRARY_PATH}

WORKDIR /tmp

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get install git-lfs
RUN git clone https://viotemp1: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@github.com/viotemp1/ethminer.git && pwd

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' \
	&& apt-get update && apt-get install -y kitware-archive-keyring \
	&& rm /etc/apt/trusted.gpg.d/kitware.gpg && apt-get update && apt-get install -y cmake

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O cuda-ubuntu2004.pin
RUN mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
	&& apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub \
	&& add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"

#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cuda-toolkit-11-3 cuda

RUN cd ethminer && pwd \
#  &&  
#  && cd nheqminer/cpu_xenoncat/asm_linux \
#  && sh assemble.sh \
#  && cd ../../../ \
#  && mkdir build/ \
#  && cd build/ \
#  && cmake -DUSE_CUDA_DJEZO=OFF -DUSE_CPU_XENONCAT=ON -DUSE_CPU_TROMP=OFF -DUSE_CUDA_TROMP=ON ../nheqminer \
#  && make -j $(nproc) \
#  && cp ./ethminer/ethminer /usr/local/bin/ethminer \
#  && chmod +x /usr/local/bin/ethminer

#RUN rm -rf /tmp/*
#RUN useradd -ms /bin/bash nheqminer
#RUN usermod -aG vglusers nheqminer
#USER nheqminer

#RUN mkdir -p /home/ethminer
#WORKDIR /home/ethminer
#ENTRYPOINT ["/usr/local/bin/ethminer"]
