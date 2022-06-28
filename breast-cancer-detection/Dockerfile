FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-devel

# Update NVIDIA's apt-key
# Announcement: https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation/212772
ENV DISTRO ubuntu1804
ENV CPU_ARCH x86_64
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$DISTRO/$CPU_ARCH/3bf863cc.pub

RUN apt-get update && apt-get install -y git libgl1-mesa-glx libglib2.0-0

WORKDIR /workspace
RUN git clone https://github.com/jimmywhitaker/breast_cancer_classifier.git /workspace
RUN pip install --upgrade pip && pip install -r requirements.txt
RUN pip install matplotlib --ignore-installed

RUN apt-get -y install tree

COPY . /workspace
