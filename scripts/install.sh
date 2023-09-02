#!/usr/bin/env bash
echo "Deleting Automatic1111 Web UI"
rm -rf /workspace/stable-diffusion-webui

echo "Deleting venv"
rm -rf /workspace/venv

echo "Cloning A1111 repo to /workspace"
cd /workspace
git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

echo "Installing Ubuntu updates"
apt update
apt -y upgrade

echo "Creating and activating venv"
cd stable-diffusion-webui
python -m venv /workspace/venv
source /workspace/venv/bin/activate

echo "Installing Torch"
pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

echo "Installing xformers"
pip install --no-cache-dir xformers

echo "Installing A1111 Web UI"
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/install-automatic.py
python -m install-automatic --skip-torch-cuda-test

echo "Cloning ControlNet extension repo"
git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

echo "Installing dependencies for ControlNet"
cd extensions/sd-webui-controlnet
pip install -r requirements.txt

echo "Installing RunPod Serverless dependencies"
cd /workspace/stable-diffusion-webui
pip3 install huggingface_hub runpod

echo "Downloading Deliberate v2 model"
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
wget -O deliberate_v2.safetensors https://civitai.com/api/download/models/

echo "Downloading ControlNet models"
mkdir -p /workspace/stable-diffusion-webui/models/ControlNet
cd /workspace/stable-diffusion-webui/models/ControlNet
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth
wget https://huggingface.co/ioclab/ioc-controlnet/resolve/main/models/control_v1p_sd15_brightness.safetensors
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth

echo "Downloading Upscalers"
cd /workspace/stable-diffusion-webui/models/ESRGAN
wget https://huggingface.co/ashleykleynhans/upscalers/resolve/main/4x-UltraSharp.pth
wget https://huggingface.co/ashleykleynhans/upscalers/resolve/main/lollypop.pth

echo "Creating log directory"
mkdir -p /workspace/logs

echo "Installing config files"
cd /workspace/stable-diffusion-webui
rm webui-user.sh config.json ui-config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/webui-user.sh
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/ui-config.json

echo "Starting A1111 Web UI"
deactivate
export HF_HOME="/workspace"
cd /workspace/stable-diffusion-webui
./webui.sh -f
