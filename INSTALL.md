# RAGME Installation Guide

## Prerequisites

### Hardware Requirements
- **CPU**: Intel Core i9 13th Gen (or equivalent)
- **GPU**: NVIDIA RTX 4060 8GB VRAM
- **RAM**: 32GB recommended (minimum 16GB)
- **Storage**: 100GB free space (SSD recommended)
- **OS**: Kali Linux (or Ubuntu/Debian-based)

### Software Requirements
- Python 3.11+
- CUDA 12.1+ with NVIDIA drivers
- Docker 24+
- Git

---

## Phase 0: Foundation Setup

### Step 1: Clone Repository

```bash
cd ~
git clone <repository-url> RAGme
cd RAGme
git checkout claude/expert-systems-architecture-012MLTJaw4ugXgKt4GKh7vo2
```

### Step 2: Verify Python Version

```bash
python3 --version
# Should show Python 3.11+

# If not installed:
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev
```

### Step 3: Verify NVIDIA GPU and CUDA

```bash
# Check GPU
nvidia-smi

# Should show RTX 4060 with CUDA 12.x
# If not:
# Install NVIDIA drivers:
sudo apt install nvidia-driver-535  # or latest stable
sudo reboot

# Install CUDA Toolkit:
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.3.0/local_installers/cuda-repo-ubuntu2204-12-3-local_12.3.0-545.23.06-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-3-local_12.3.0-545.23.06-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-3-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt update
sudo apt install cuda-toolkit-12-3
```

### Step 4: Install Docker

```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install Docker
sudo apt update
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Test Docker
docker run hello-world
```

### Step 5: Install NVIDIA Container Toolkit

```bash
# Configure repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install
sudo apt update
sudo apt install -y nvidia-container-toolkit

# Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Test GPU in Docker
docker run --rm --gpus all nvidia/cuda:12.1-base-ubuntu22.04 nvidia-smi
```

### Step 6: Create Virtual Environment

```bash
cd ~/RAGme
python3 -m venv venv
source venv/bin/activate
```

### Step 7: Install Dependencies

```bash
# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install basic dependencies first
pip install -r requirements.txt

# IMPORTANT: Reinstall llama-cpp-python with CUDA support
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python==0.2.90 --force-reinstall --no-cache-dir

# This will take 10-15 minutes to compile
```

### Step 8: Download Model

```bash
# Create models directory
mkdir -p ~/RAGme/data/models

# Download Qwen2.5-VL-7B-Instruct-abliterated GGUF Q4_K_M
# Option 1: Using huggingface-cli
pip install huggingface-hub
huggingface-cli download mradermacher/Qwen2.5-VL-7B-Instruct-abliterated-i1-GGUF \
    Qwen2.5-VL-7B-Instruct-abliterated.i1-IQ4_XS.gguf \
    --local-dir ~/RAGme/data/models

# Option 2: Direct download (if available)
cd ~/RAGme/data/models
wget <model-url>

# Verify file size (~4.5GB for Q4_K_M)
ls -lh ~/RAGme/data/models/
```

### Step 9: Initialize Databases

```bash
cd ~/RAGme
source venv/bin/activate

# Create database directories
mkdir -p data/vector_db data/adapters

# Initialize SQLite with schema
python3 << 'PYTHON'
import sqlite3
import os

db_path = "data/registry.db"
schema_path = "src/persistence/schema.sql"

conn = sqlite3.connect(db_path)
with open(schema_path, 'r') as f:
    schema = f.read()
conn.executescript(schema)
conn.commit()
conn.close()

print(f"✅ Database initialized: {db_path}")
PYTHON
```

### Step 10: Create Environment File

```bash
cp .env.example .env

# Edit .env with your paths
nano .env
# Update RAGME_HOME and other paths as needed
```

### Step 11: Verify Installation

```bash
# Test Python imports
python3 << 'PYTHON'
try:
    import llama_cpp
    print("✅ llama-cpp-python installed")
    print(f"   CUDA support: {llama_cpp.llama_supports_gpu_offload()}")
except Exception as e:
    print(f"❌ llama-cpp-python: {e}")

try:
    import chromadb
    print("✅ ChromaDB installed")
except Exception as e:
    print(f"❌ ChromaDB: {e}")

try:
    import docker
    client = docker.from_env()
    print(f"✅ Docker accessible: {client.version()['Version']}")
except Exception as e:
    print(f"❌ Docker: {e}")

print("\n=== GPU Check ===")
import torch
if torch.cuda.is_available():
    print(f"✅ CUDA available")
    print(f"   Device: {torch.cuda.get_device_name(0)}")
    print(f"   VRAM: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
else:
    print("❌ CUDA not available")
PYTHON
```

### Step 12: Run Tests

```bash
# Run basic tests
pytest tests/ -v

# Should see test structure (tests will be implemented in later phases)
```

---

## Verification Checklist

Before proceeding to Phase 1, verify:

- [ ] Python 3.11+ installed
- [ ] NVIDIA drivers installed (nvidia-smi shows RTX 4060)
- [ ] CUDA 12.1+ installed
- [ ] Docker installed and running
- [ ] NVIDIA Container Toolkit installed
- [ ] GPU accessible in Docker containers
- [ ] Virtual environment created
- [ ] All Python dependencies installed
- [ ] llama-cpp-python compiled with CUDA support
- [ ] Model downloaded (~4.5GB)
- [ ] SQLite database initialized
- [ ] ChromaDB accessible
- [ ] .env file configured
- [ ] Test suite runs without import errors

---

## Troubleshooting

### llama-cpp-python CUDA compilation fails

```bash
# Ensure CUDA is in PATH
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Try compilation again
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python==0.2.90 --force-reinstall --no-cache-dir --verbose
```

### Docker permission denied

```bash
sudo usermod -aG docker $USER
newgrp docker
# Or logout and login again
```

### NVIDIA runtime not found in Docker

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Model download too slow

```bash
# Use aria2c for faster parallel downloads
sudo apt install aria2
aria2c -x 16 -s 16 <model-url>
```

---

## Next Steps

Once Phase 0 is complete:
1. Commit your configuration changes
2. Verify all checklist items pass
3. Proceed to **Phase 1: Core Intelligence Layer**

See `doc/04_implementation_plan.md` for detailed Phase 1 tasks.

---

## Storage Requirements

After Phase 0 completion:
- Model: ~5 GB
- Dependencies: ~3 GB
- Docker images: ~2 GB
- **Total**: ~10 GB

This will grow to ~27 GB after 6 months of use (tools, knowledge, adapters).

---

## Estimated Time

- Hardware setup (Docker, CUDA): 1-2 hours
- Python environment & dependencies: 30-45 minutes
- Model download: 30 minutes - 2 hours (depending on internet speed)
- Database initialization: 5 minutes
- Verification: 15 minutes

**Total: 3-5 hours for complete Phase 0 setup**
