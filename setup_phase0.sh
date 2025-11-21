#!/bin/bash

################################################################################
# RAGME Phase 0: Complete Hardware Setup Script
# For: Kali Linux with RTX 4060 8GB
# Version: 1.0
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

log_info "RAGME Phase 0 Hardware Setup"
log_info "Project Directory: $PROJECT_DIR"
echo ""

################################################################################
# STEP 0: Prerequisites Check
################################################################################

log_info "=== Step 0: Checking Prerequisites ==="

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This script must run on Linux (detected: $OSTYPE)"
    exit 1
fi
log_success "Operating System: Linux"

# Check disk space (need 15GB)
AVAILABLE_GB=$(df -BG "$PROJECT_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_GB" -lt 15 ]; then
    log_error "Insufficient disk space. Need 15GB, have ${AVAILABLE_GB}GB"
    exit 1
fi
log_success "Disk Space: ${AVAILABLE_GB}GB available"

# Check NVIDIA GPU
if ! command -v nvidia-smi &> /dev/null; then
    log_error "nvidia-smi not found. Please install NVIDIA drivers first."
    exit 1
fi

# Get GPU info
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "Unknown")
GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null || echo "0")
log_success "GPU Detected: $GPU_NAME (${GPU_VRAM}MB VRAM)"

if [ "$GPU_VRAM" -lt 7000 ]; then
    log_warning "Recommended: 8GB VRAM minimum. You have: ${GPU_VRAM}MB"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 9 ]); then
    log_error "Python 3.9+ required. Found: $PYTHON_VERSION"
    exit 1
fi
log_success "Python Version: $PYTHON_VERSION"

# Check for sudo access
if ! sudo -n true 2>/dev/null; then
    log_warning "This script requires sudo access for Docker installation"
    sudo -v || { log_error "Cannot obtain sudo access"; exit 1; }
fi
log_success "Sudo access: Available"

echo ""
log_info "Prerequisites check complete!"
echo ""

################################################################################
# STEP 1: Install Docker
################################################################################

log_info "=== Step 1: Installing Docker ==="

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    log_warning "Docker already installed: $DOCKER_VERSION"
    read -p "Skip Docker installation? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        log_info "Skipping Docker installation"
    else
        INSTALL_DOCKER=true
    fi
else
    INSTALL_DOCKER=true
fi

if [ "$INSTALL_DOCKER" = true ]; then
    log_info "Updating package index..."
    sudo apt update -qq

    log_info "Installing Docker packages..."
    sudo apt install -y docker.io docker-compose

    log_info "Starting Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker

    log_info "Adding current user to docker group..."
    sudo usermod -aG docker "$USER"

    log_success "Docker installed successfully"
    log_warning "You may need to log out and back in for docker group to take effect"

    # Try to use docker without sudo for this session
    if ! docker ps &> /dev/null; then
        log_warning "Running newgrp docker to activate group (may require password)"
        # Note: newgrp creates a new shell, so we'll just use sudo for now
    fi
else
    log_info "Docker installation skipped"
fi

# Verify Docker works
if sudo docker run --rm hello-world &> /dev/null; then
    log_success "Docker verification: Working"
else
    log_error "Docker verification failed"
    exit 1
fi

echo ""

################################################################################
# STEP 2: Install NVIDIA Container Toolkit
################################################################################

log_info "=== Step 2: Installing NVIDIA Container Toolkit ==="

if dpkg -l | grep -q nvidia-container-toolkit; then
    log_warning "NVIDIA Container Toolkit already installed"
    read -p "Skip NVIDIA Container Toolkit installation? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        log_info "Skipping NVIDIA Container Toolkit installation"
        INSTALL_NVIDIA_TOOLKIT=false
    else
        INSTALL_NVIDIA_TOOLKIT=true
    fi
else
    INSTALL_NVIDIA_TOOLKIT=true
fi

if [ "$INSTALL_NVIDIA_TOOLKIT" = true ]; then
    log_info "Setting up NVIDIA Docker repository..."

    distribution=$(. /etc/os-release; echo $ID$VERSION_ID)

    # Add NVIDIA GPG key
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
        sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

    # Add repository
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    log_info "Installing NVIDIA Container Toolkit..."
    sudo apt update -qq
    sudo apt install -y nvidia-container-toolkit

    log_info "Configuring Docker for NVIDIA runtime..."
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker

    log_success "NVIDIA Container Toolkit installed"
else
    log_info "NVIDIA Container Toolkit installation skipped"
fi

# Verify GPU in Docker
log_info "Verifying GPU access in Docker..."
if sudo docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    log_success "GPU verification: Docker can access GPU"
else
    log_error "GPU verification failed - Docker cannot access GPU"
    exit 1
fi

echo ""

################################################################################
# STEP 3: Download Model
################################################################################

log_info "=== Step 3: Downloading Qwen2.5-VL-7B Model ==="

MODEL_DIR="$PROJECT_DIR/data/models"
MODEL_FILE="$MODEL_DIR/qwen2.5-vl-7b-instruct-abliterated-q4_k_m.gguf"

mkdir -p "$MODEL_DIR"

if [ -f "$MODEL_FILE" ]; then
    MODEL_SIZE=$(du -h "$MODEL_FILE" | cut -f1)
    log_warning "Model already exists: $MODEL_FILE ($MODEL_SIZE)"
    read -p "Re-download model? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping model download"
        DOWNLOAD_MODEL=false
    else
        DOWNLOAD_MODEL=true
    fi
else
    DOWNLOAD_MODEL=true
fi

if [ "$DOWNLOAD_MODEL" = true ]; then
    log_info "This will download ~5GB. It may take 30min - 2 hours depending on your connection."
    log_info "You can also manually download from Hugging Face and place it in:"
    log_info "  $MODEL_FILE"
    echo ""
    read -p "Download now? (Y/n) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        # Check if huggingface-cli is available
        if ! command -v huggingface-cli &> /dev/null; then
            log_info "Installing huggingface-hub for downloads..."
            pip3 install -q huggingface-hub[cli]
        fi

        log_info "Downloading model (this will take a while)..."
        log_info "Model: Qwen/Qwen2.5-VL-7B-Instruct-GGUF"
        log_info "File: qwen2.5-vl-7b-instruct-q4_k_m.gguf"

        # Download using huggingface-cli
        huggingface-cli download \
            Qwen/Qwen2.5-VL-7B-Instruct-GGUF \
            qwen2.5-vl-7b-instruct-q4_k_m.gguf \
            --local-dir "$MODEL_DIR" \
            --local-dir-use-symlinks False

        # Rename to our expected filename
        if [ -f "$MODEL_DIR/qwen2.5-vl-7b-instruct-q4_k_m.gguf" ]; then
            mv "$MODEL_DIR/qwen2.5-vl-7b-instruct-q4_k_m.gguf" "$MODEL_FILE"
            log_success "Model downloaded successfully"
        else
            log_error "Model download failed"
            exit 1
        fi
    else
        log_warning "Model download skipped - you must download manually later"
        log_info "Manual download instructions in INSTALL.md"
    fi
fi

# Verify model file
if [ -f "$MODEL_FILE" ]; then
    MODEL_SIZE=$(du -h "$MODEL_FILE" | cut -f1)
    log_success "Model file: $MODEL_FILE ($MODEL_SIZE)"
else
    log_warning "Model file not found - download skipped"
fi

echo ""

################################################################################
# STEP 4: Setup Python Virtual Environment
################################################################################

log_info "=== Step 4: Setting Up Python Virtual Environment ==="

VENV_DIR="$PROJECT_DIR/venv"

if [ -d "$VENV_DIR" ]; then
    log_warning "Virtual environment already exists: $VENV_DIR"
    read -p "Recreate virtual environment? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removing existing venv..."
        rm -rf "$VENV_DIR"
        CREATE_VENV=true
    else
        CREATE_VENV=false
    fi
else
    CREATE_VENV=true
fi

if [ "$CREATE_VENV" = true ]; then
    log_info "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    log_success "Virtual environment created"
fi

# Activate venv
log_info "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
log_info "Upgrading pip..."
pip install --upgrade pip -q

log_success "Virtual environment ready"
echo ""

################################################################################
# STEP 5: Install Python Dependencies
################################################################################

log_info "=== Step 5: Installing Python Dependencies ==="

# Install basic dependencies first
log_info "Installing basic dependencies..."
pip install -q wheel setuptools

# Install requirements (except llama-cpp-python)
log_info "Installing requirements.txt (this may take 10-15 minutes)..."
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    # Filter out llama-cpp-python for now
    grep -v "llama-cpp-python" "$PROJECT_DIR/requirements.txt" > /tmp/requirements_temp.txt
    pip install -q -r /tmp/requirements_temp.txt
    rm /tmp/requirements_temp.txt
    log_success "Base dependencies installed"
else
    log_error "requirements.txt not found!"
    exit 1
fi

# Install llama-cpp-python with CUDA support
log_info "Installing llama-cpp-python with CUDA support..."
log_info "This will compile from source (10-15 minutes)..."

# Check CUDA version
CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}' || echo "unknown")
log_info "Detected CUDA Version: $CUDA_VERSION"

# Install with CUDA support
CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python==0.2.90 --force-reinstall --no-cache-dir

if [ $? -eq 0 ]; then
    log_success "llama-cpp-python installed with CUDA support"
else
    log_error "Failed to install llama-cpp-python with CUDA"
    log_info "Falling back to CPU-only version..."
    pip install llama-cpp-python==0.2.90
fi

# Verify llama-cpp-python
log_info "Verifying llama-cpp-python installation..."
python3 -c "from llama_cpp import Llama; print('llama-cpp-python: OK')" 2>/dev/null
if [ $? -eq 0 ]; then
    log_success "llama-cpp-python verification: Passed"
else
    log_error "llama-cpp-python verification: Failed"
    exit 1
fi

echo ""

################################################################################
# STEP 6: Initialize Databases
################################################################################

log_info "=== Step 6: Initializing Databases ==="

# Create data directories
mkdir -p "$PROJECT_DIR/data/vector_db"
mkdir -p "$PROJECT_DIR/data/adapters"
mkdir -p "$PROJECT_DIR/logs"
mkdir -p "$PROJECT_DIR/tools"
mkdir -p "$PROJECT_DIR/knowledge"
mkdir -p "$PROJECT_DIR/sandbox"

# Initialize SQLite database
DB_FILE="$PROJECT_DIR/data/registry.db"
SCHEMA_FILE="$PROJECT_DIR/src/persistence/schema.sql"

if [ -f "$DB_FILE" ]; then
    log_warning "Database already exists: $DB_FILE"
    read -p "Recreate database (WARNING: loses all data)? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$DB_FILE"
        INIT_DB=true
    else
        INIT_DB=false
    fi
else
    INIT_DB=true
fi

if [ "$INIT_DB" = true ]; then
    if [ -f "$SCHEMA_FILE" ]; then
        log_info "Creating SQLite database from schema..."
        sqlite3 "$DB_FILE" < "$SCHEMA_FILE"
        log_success "Database initialized: $DB_FILE"

        # Verify database
        TABLE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';")
        log_info "Database tables created: $TABLE_COUNT"
    else
        log_error "Schema file not found: $SCHEMA_FILE"
        exit 1
    fi
else
    log_info "Database initialization skipped"
fi

# Initialize ChromaDB
log_info "Initializing ChromaDB..."
python3 << 'EOF'
import chromadb
try:
    client = chromadb.PersistentClient(path="data/vector_db")
    # Create default collections
    client.get_or_create_collection("knowledge_modules")
    client.get_or_create_collection("conversations")
    print("ChromaDB initialized successfully")
except Exception as e:
    print(f"ChromaDB initialization failed: {e}")
    exit(1)
EOF

if [ $? -eq 0 ]; then
    log_success "ChromaDB initialized"
else
    log_error "ChromaDB initialization failed"
    exit 1
fi

echo ""

################################################################################
# STEP 7: Create Environment File
################################################################################

log_info "=== Step 7: Creating Environment Configuration ==="

ENV_FILE="$PROJECT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    log_warning ".env file already exists"
    read -p "Overwrite .env file? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping .env creation"
        CREATE_ENV=false
    else
        CREATE_ENV=true
    fi
else
    CREATE_ENV=true
fi

if [ "$CREATE_ENV" = true ]; then
    log_info "Creating .env from template..."

    cat > "$ENV_FILE" << EOF
# RAGME Environment Configuration
# Generated: $(date)

# Model Configuration
MODEL_PATH=$MODEL_FILE
CONTEXT_LENGTH=4096
GPU_LAYERS=-1

# Database Paths
REGISTRY_DB=$DB_FILE
VECTOR_DB=$PROJECT_DIR/data/vector_db

# Directories
TOOLS_DIR=$PROJECT_DIR/tools
KNOWLEDGE_DIR=$PROJECT_DIR/knowledge
ADAPTERS_DIR=$PROJECT_DIR/data/adapters
LOGS_DIR=$PROJECT_DIR/logs

# API Configuration (if using REST API)
API_HOST=127.0.0.1
API_PORT=8000

# Logging
LOG_LEVEL=INFO
LOG_FILE=$PROJECT_DIR/logs/ragme.log

# Docker Settings
DOCKER_SANDBOX_MEMORY=2g
DOCKER_SANDBOX_CPU=2.0
DOCKER_SANDBOX_TIMEOUT=300
EOF

    log_success ".env file created"
else
    log_info ".env creation skipped"
fi

echo ""

################################################################################
# STEP 8: Verification
################################################################################

log_info "=== Step 8: Final Verification ==="

echo ""
log_info "Running verification checks..."
echo ""

# 1. Docker
if sudo docker ps &> /dev/null; then
    log_success "✓ Docker daemon running"
else
    log_error "✗ Docker daemon not running"
fi

# 2. GPU in Docker
if sudo docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    log_success "✓ GPU accessible in Docker"
else
    log_warning "✗ GPU not accessible in Docker"
fi

# 3. Model file
if [ -f "$MODEL_FILE" ]; then
    log_success "✓ Model file present ($(du -h "$MODEL_FILE" | cut -f1))"
else
    log_warning "✗ Model file missing (download manually)"
fi

# 4. Database
if [ -f "$DB_FILE" ]; then
    TABLE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';")
    log_success "✓ Database initialized ($TABLE_COUNT tables)"
else
    log_error "✗ Database not initialized"
fi

# 5. ChromaDB
if [ -d "$PROJECT_DIR/data/vector_db" ]; then
    log_success "✓ ChromaDB directory exists"
else
    log_error "✗ ChromaDB directory missing"
fi

# 6. Python environment
if [ -d "$VENV_DIR" ]; then
    log_success "✓ Virtual environment exists"
else
    log_error "✗ Virtual environment missing"
fi

# 7. llama-cpp-python
source "$VENV_DIR/bin/activate"
if python3 -c "from llama_cpp import Llama" 2>/dev/null; then
    log_success "✓ llama-cpp-python installed"
else
    log_error "✗ llama-cpp-python not working"
fi

# 8. CUDA support
CUDA_TEST=$(python3 << 'EOF'
from llama_cpp import Llama
import llama_cpp
# Check if CUDA is available
if hasattr(llama_cpp.llama_cpp, 'GGML_USE_CUDA'):
    print("yes")
else:
    print("no")
EOF
)

if [ "$CUDA_TEST" = "yes" ]; then
    log_success "✓ CUDA support enabled in llama-cpp-python"
else
    log_warning "✗ CUDA support not detected (CPU-only mode)"
fi

echo ""

################################################################################
# COMPLETION
################################################################################

log_success "========================================="
log_success "   Phase 0 Setup Complete!"
log_success "========================================="
echo ""

log_info "Next steps:"
echo "  1. Activate environment: source venv/bin/activate"
echo "  2. Test model loading:   python3 -c 'from llama_cpp import Llama; Llama(model_path=\"$MODEL_FILE\", n_gpu_layers=-1)'"
echo "  3. Start Phase 1 development"
echo ""

log_info "Useful commands:"
echo "  • Check GPU:      nvidia-smi"
echo "  • Check Docker:   docker ps"
echo "  • View logs:      tail -f logs/ragme.log"
echo "  • Run tests:      pytest tests/"
echo ""

log_warning "IMPORTANT: If you installed Docker for the first time:"
echo "  Log out and back in for 'docker' group to take effect"
echo "  Or run: newgrp docker"
echo ""

log_info "Configuration files:"
echo "  • System config:  config/system.yaml"
echo "  • Policy config:  config/policy.yaml"
echo "  • Environment:    .env"
echo ""

log_success "Ready for Phase 1: Intelligence Layer Development"
echo ""
