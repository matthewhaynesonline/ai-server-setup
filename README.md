# AI and ML Server Setup

This is the code that accompanies the [AI Server from Scratch in AWS video]().

This project walks through setting up an AWS EC2 instance optimized for generative AI and machine learning tasks, using NVIDIA and Docker on Ubuntu.

### Prerequisites

- An AWS account
- Basic knowledge of:
  - AWS (EC2)
  - Virtual Machines
  - Linux / Command Line / SSH
- Familiarity with Docker and containerization concepts

### Goals

1. Configure a compute-optimized VM from scratch (starting with a blank Ubuntu image)
2. Ensure portability to avoid vendor lock-in and reduce dependence on platform-specific tools
3. Create a flexible environment suitable for various AI and ML frameworks
4. Streamline deployments by creating a custom image with Packer

#### Why EC2 vs Bedrock, HuggingFace Endpoints, etc.

An EC2 is not the perfect choice for all projects. There may be cases where a hosted API / an API that charges a price per token is cheaper and / or easier to get up an running (an API will almost always be easier to get up and running).

Here are the reason this guide uses an EC2:

1. Price ceiling: the price for the EC2 and storage has a predictable ceiling, so there shouldn't be any surprise bills
2. Versatile: since an EC2 is ostensibly a VM (with a GPU), we can run all kinds of projects on it, not just the use cases that are supported by an API / platform provider
3. Portable: the steps to configure the EC2 should generally apply to other Linux instances

### Setup / Instructions / Notes

#### AWS

**Make sure to create an aws.env file with your settings.** `cd aws; cp aws.env.example aws.env`

See the aws directory. There is an example setup script that will configure the specified EC2 and a deploy script that copy the code to the EC2 and start the stack.

**NOTE: if running on a non standard port (not 80 or 443) make sure to allow inbound traffic to the EC2 on that port.**

##### Lambda Auto Stop EC2

An example Lambda function is provided to stop all EC2 instances. The demo'd use for this is to stop all EC2s at midnight to prevent long running instances from incurring a higher bill.

##### Packer

An example Packer file is provided to generate a custom AMI from the setup steps in this guide. This will allow you to quickly deploy a baseline instance with NVIDIA / Docker support without having to reconfigure from scratch every time.

#### llama.cpp

llama.cpp is included just to test that the server is working as expected, both natively and in a container. It is added as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

##### Compile with CUDA and Support for NVIDIA T4 (nvidia 7.5)

- https://github.com/ggerganov/llama.cpp/blob/master/docs/build.md#cuda
- https://developer.nvidia.com/cuda-gpus

```sh
make clean
CUDA_DOCKER_ARCH=compute_75 GGML_CUDA=1 make
```

#### Download Model

```sh
cd models

# Use Bartowski gguf to fix issues with llama.cpp
curl -O -L "https://huggingface.co/bartowski/Phi-3.1-mini-4k-instruct-GGUF/resolve/main/Phi-3.1-mini-4k-instruct-Q6_K_L.gguf"
```

### Resources

- [Auto Stop EC2 Using AWS Lambda](https://repost.aws/knowledge-center/start-stop-lambda-eventbridge)
- [Install Docker Compose on Linux](https://docs.docker.com/compose/install/linux/)
- [Ubuntu NVIDIA Driver Docs](https://ubuntu.com/server/docs/nvidia-drivers-installation)
- [NVIDIA CUDA Installation Guide for Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
  - [CUDA GPU Compatibility List](https://developer.nvidia.com/cuda-gpus)
- [NVIDIA Container Toolkit Guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [Elasticsearch / Opensearch virtual memory](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)
  - [https://stackoverflow.com/q/51445846](https://stackoverflow.com/q/51445846)
- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [Distantmagic's Paddler Installation on AWS EC2 CUDA Instances Notes](https://github.com/distantmagic/paddler/blob/v0.3.0/infra/tutorial-installing-llamacpp-aws-cuda.md)
  - This has been deprecated in favor of [LLMOps Handbook](https://github.com/distantmagic/llmops-handbook)
- [Packer Machine Image Builder](https://www.packer.io/)
  - [Packer AWS Tutorial](https://developer.hashicorp.com/packer/tutorials/aws-get-started)
