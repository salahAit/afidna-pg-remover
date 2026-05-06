#!/bin/bash
# Enable access to system-wide CUDA and cuDNN libraries without re-installing them
export LD_LIBRARY_PATH=/home/msi/.local/lib/python3.12/site-packages/nvidia/cudnn/lib:/usr/local/lib/ollama/mlx_cuda_v13:/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

source venv/bin/activate
python3 backend/main.py
