#!/usr/bin/env bash

model_file="./models/Phi-3.1-mini-4k-instruct-Q6_K_L.gguf"

port=80

# MAKE SURE TO LIMIT CONTEXT SIZE WITH LARGE MODELS
# contextsize=36000

# Can't use chat server and embedding server at same time
# https://github.com/ggerganov/llama.cpp/issues/8076#issuecomment-2185147824

echo "Starting llama server using $model_file on port $port"
./llama.cpp/llama-server -m $model_file --host 0.0.0.0 --port $port --n-gpu-layers 99 --flash-attn --mlock
# ./llama.cpp/llama-server -m $model_file --host 0.0.0.0 --port $port --n-gpu-layers 99 --ctx-size $contextsize --flash-attn --mlock
