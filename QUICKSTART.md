# RAGME Quick Start Guide

**For Kali Linux with RTX 4060 8GB**

## Prerequisites

Before running the setup script, ensure you have:

1. **NVIDIA Drivers Installed**
   ```bash
   nvidia-smi  # Should show your GPU info
   ```
   If not installed: `sudo apt install nvidia-driver nvidia-cuda-toolkit`

2. **Internet Connection** (for downloading ~10GB of packages/models)

3. **15GB Free Disk Space**
   ```bash
   df -h .  # Check available space
   ```

4. **Sudo Access**
   ```bash
   sudo -v  # Test sudo access
   ```

---

## One-Command Installation

```bash
cd ~/RAGme
./setup_phase0.sh
```

**That's it!** The script will:
- ✓ Check all prerequisites
- ✓ Install Docker + NVIDIA Container Toolkit
- ✓ Download Qwen2.5-VL-7B model (~5GB)
- ✓ Install Python dependencies with CUDA support
- ✓ Initialize databases (SQLite + ChromaDB)
- ✓ Configure environment
- ✓ Verify everything works

**Time Required**: 1-3 hours (mostly model download time)

---

## What You'll Be Asked

The script is interactive and will ask for confirmation before:
- Installing Docker (if not already installed)
- Installing NVIDIA Container Toolkit
- Downloading the 5GB model file
- Recreating existing files/databases

**Recommended**: Answer "Y" (yes) to everything for first-time setup.

---

## After Installation

### 1. Activate Environment
```bash
source venv/bin/activate
```

### 2. Verify GPU Access
```bash
python3 << 'EOF'
from llama_cpp import Llama

# This will load the model on GPU
llm = Llama(
    model_path="data/models/qwen2.5-vl-7b-instruct-abliterated-q4_k_m.gguf",
    n_gpu_layers=-1,  # Load all layers on GPU
    verbose=False
)

print("✓ Model loaded successfully on GPU!")
print(f"✓ Context length: {llm.n_ctx()}")

# Test generation
response = llm("Hello! Say 'RAGME is ready!'", max_tokens=20)
print(f"✓ Test response: {response['choices'][0]['text']}")
EOF
```

Expected output:
```
✓ Model loaded successfully on GPU!
✓ Context length: 4096
✓ Test response: RAGME is ready!
```

### 3. Verify Docker + GPU
```bash
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

Expected: Should show your GPU info inside container.

---

## Troubleshooting

### Docker Group Not Active

**Symptom**: `permission denied while trying to connect to Docker daemon`

**Fix**:
```bash
# Log out and back in, OR:
newgrp docker

# OR use sudo for now:
sudo docker ps
```

### Model Download Fails

**Symptom**: Hugging Face download timeout or error

**Manual Download**:
1. Go to: https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct-GGUF
2. Download: `qwen2.5-vl-7b-instruct-q4_k_m.gguf` (~5GB)
3. Place in: `~/RAGme/data/models/qwen2.5-vl-7b-instruct-abliterated-q4_k_m.gguf`
4. Re-run setup script (it will detect existing file)

### CUDA Not Detected

**Symptom**: `CUDA support not detected (CPU-only mode)`

**Fix**:
```bash
# Check NVIDIA drivers
nvidia-smi

# Reinstall llama-cpp-python with CUDA
source venv/bin/activate
CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python==0.2.90 --force-reinstall --no-cache-dir
```

### Out of VRAM

**Symptom**: `CUDA out of memory` when loading model

**Fix 1 - Use smaller quantization**:
Download Q4_0 instead of Q4_K_M (saves ~500MB)

**Fix 2 - Reduce GPU layers**:
```python
# In .env file, change:
GPU_LAYERS=35  # Instead of -1 (all layers)
```

---

## Configuration Files

After setup, you can customize:

### `config/system.yaml`
- Model parameters (temperature, max_tokens)
- Sandbox limits (memory, CPU, timeout)
- LoRA training settings

### `config/policy.yaml`
- Trust levels for auto-approval
- Category permissions
- Fine-grained rules

### `.env`
- File paths
- API settings
- Logging configuration

---

## Next Steps

Once Phase 0 is complete:

1. **Explore the codebase**
   ```bash
   tree src/  # View project structure
   ```

2. **Run tests** (once Phase 1 is implemented)
   ```bash
   pytest tests/ -v
   ```

3. **Start RAGME** (once implementation is complete)
   ```bash
   ragme  # CLI interface
   # Or:
   ragme serve  # REST API server
   ```

4. **Read documentation**
   ```bash
   cat doc/README.md
   ```

---

## System Resources After Setup

| Component | Disk | RAM (Idle) | VRAM |
|-----------|------|------------|------|
| Docker + Toolkit | 3GB | 100MB | 0MB |
| Python packages | 3GB | 0MB | 0MB |
| Model (GGUF) | 5GB | 0MB | 0MB |
| Databases | 10MB | 0MB | 0MB |
| **When Running** |  |  |  |
| RAGME system | - | ~1.5GB | ~7.5GB |
| Active sandbox | - | +2GB | 0MB |

---

## Uninstallation

If you want to completely remove everything:

```bash
# Stop and remove Docker
sudo systemctl stop docker
sudo apt remove docker.io nvidia-container-toolkit
sudo apt autoremove
sudo rm -rf /var/lib/docker

# Remove RAGME project
rm -rf ~/RAGme

# Remove user from docker group
sudo deluser $USER docker
```

---

## Support

If you encounter issues:

1. Check `logs/ragme.log` for error messages
2. Review `INSTALL.md` for detailed manual steps
3. Verify prerequisites with `nvidia-smi`, `python3 --version`
4. Ensure 15GB free disk space

---

## Summary

```bash
# Full installation in 3 commands:
cd ~/RAGme
./setup_phase0.sh
source venv/bin/activate

# Verify:
nvidia-smi                    # GPU detected
docker ps                     # Docker running
python3 -c "from llama_cpp import Llama; print('OK')"  # Python ready
```

**You're ready to proceed to Phase 1!** 🚀
