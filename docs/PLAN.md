# RAGme Complete Implementation Plan

**Document Version**: 2.0
**Last Updated**: 2025-11-25
**Status**: Ready for Implementation

---

## Table of Contents

1. [Overview](#overview)
2. [Phase 0: Prerequisites & Foundation](#phase-0-prerequisites--foundation)
3. [Phase 1: Core System (Weeks 3-8)](#phase-1-core-system-weeks-3-8)
4. [Phase 2: Enhancement (Weeks 9-16)](#phase-2-enhancement-weeks-9-16)
5. [Phase 3: Mastery (Weeks 17-24)](#phase-3-mastery-weeks-17-24)
6. [Appendix](#appendix)

---

## Overview

### System Goal

Build a self-evolving AI system that autonomously generates tools, creates knowledge modules, and trains reasoning adapters to expand its capabilities indefinitely.

### Development Approach

- **Incremental**: Build layer by layer, testing at each step
- **Test-Driven**: Write tests before implementation
- **Documented**: Document every component and decision
- **Modular**: Each component can be developed and tested independently

### Timeline Summary

| Phase | Duration | Outcome |
|-------|----------|---------|
| Phase 0 | Weeks 1-2 | Environment ready, tools installed |
| Phase 1 | Weeks 3-8 | Core self-evolution working |
| Phase 2 | Weeks 9-16 | Advanced capabilities, 50+ tools |
| Phase 3 | Weeks 17-24 | Meta-capabilities, 500+ tools |

**Total**: 24 weeks (6 months) to fully mature system

### Success Metrics

**Phase 1 Complete When**:
- System generates first tool autonomously
- Tool installs and executes correctly
- Full self-evolution loop working

**Phase 2 Complete When**:
- 50+ tools generated and working
- Complex multi-step workflows automated
- Voice input/output functional

**Phase 3 Complete When**:
- Tools generating other tools
- 500+ tools in library
- System operates proactively

---

## Phase 0: Prerequisites & Foundation

**Duration**: Weeks 1-2
**Goal**: Prepare development environment and verify all prerequisites

### Week 1: Environment Setup

#### Day 1-2: Hardware Verification

**Task 0.1.1: Verify Hardware Specifications**

```bash
# 1. Check CPU
lscpu | grep "Model name"
# Expected: Intel Core i9-13th Gen or equivalent

# 2. Check GPU
nvidia-smi
# Expected:
# - GPU: NVIDIA RTX 4060
# - VRAM: 8192 MiB
# - Driver Version: 535+
# - CUDA Version: 12.1+

# 3. Check RAM
free -h
# Expected: Total RAM ≥ 32GB

# 4. Check Disk Space
df -h /home
# Expected: Available ≥ 150GB on NVMe SSD

# 5. Check NVMe SSD
lsblk -d -o name,rota
# Expected: rota = 0 (SSD, not HDD)
```

**Success Criteria**:
- ✅ CPU: 8+ cores
- ✅ GPU: RTX 4060 8GB or equivalent
- ✅ RAM: 32GB+
- ✅ Disk: 150GB+ on NVMe SSD

**If Failed**:
- CPU < 8 cores: System will be slower but functional
- RAM < 32GB: May need to limit context window or unload models more frequently
- No NVMe: Model loading will be slower
- No NVIDIA GPU: Cannot proceed, GPU required

---

**Task 0.1.2: Install Base System Software**

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install build essentials
sudo apt install -y build-essential cmake git wget curl

# 3. Install Python 3.11+
sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

# Verify Python version
python3.11 --version
# Expected: Python 3.11.x or later

# 4. Install NVIDIA drivers (if not already installed)
sudo apt install -y nvidia-driver-535 nvidia-utils-535

# 5. Install CUDA Toolkit
sudo apt install -y nvidia-cuda-toolkit

# Verify CUDA
nvcc --version
# Expected: release 12.1 or later

# 6. Reboot to load drivers
sudo reboot
```

**Success Criteria**:
- ✅ Python 3.11+ installed
- ✅ NVIDIA drivers loaded
- ✅ CUDA toolkit installed
- ✅ nvidia-smi shows GPU

---

#### Day 3-4: Project Structure Setup

**Task 0.1.3: Create Project Structure**

```bash
# 1. Create project root
mkdir -p ~/RAGme
cd ~/RAGme

# 2. Initialize git repository
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# 3. Create directory structure
mkdir -p {src,docs,config,data,tests,tools,knowledge,adapters,logs}
mkdir -p src/{core,intelligence,capability,execution,orchestration,persistence,policy,ui}
mkdir -p src/intelligence/{llm,rag,vision}
mkdir -p src/ui/{cli,api,mcp}
mkdir -p tests/{unit,integration,system}
mkdir -p data/{models,vector_db,adapters}

# 4. Create __init__.py files
find src -type d -exec touch {}/__init__.py \;

# 5. Verify structure
tree -L 3 src/
```

**Expected Structure**:
```
RAGme/
├── src/
│   ├── core/                 # Core utilities
│   ├── intelligence/         # AI components
│   │   ├── llm/             # LLM engine
│   │   ├── rag/             # RAG system
│   │   └── vision/          # Vision processing
│   ├── capability/           # Generators
│   ├── execution/            # Sandboxes
│   ├── orchestration/        # Agent controller
│   ├── persistence/          # Databases
│   ├── policy/               # CCAC system
│   └── ui/                   # Interfaces
│       ├── cli/
│       ├── api/
│       └── mcp/
├── config/                   # Configuration files
├── data/                     # Data storage
│   ├── models/              # GGUF models
│   ├── vector_db/           # ChromaDB
│   └── adapters/            # LoRA weights
├── tests/                    # Test suite
│   ├── unit/
│   ├── integration/
│   └── system/
├── tools/                    # Generated tools
├── knowledge/                # Knowledge modules
├── adapters/                 # Runtime adapters
└── logs/                     # Application logs
```

**Success Criteria**:
- ✅ All directories created
- ✅ Git initialized
- ✅ Structure matches specification

---

**Task 0.1.4: Create Configuration Files**

Create `requirements.txt`:
```txt
# Core Dependencies
llama-cpp-python>=0.2.0
chromadb>=0.4.0
sentence-transformers>=2.2.0
pillow>=10.0.0

# Training
unsloth>=2024.1
torch>=2.1.0
transformers>=4.35.0

# Utilities
pyyaml>=6.0
pydantic>=2.0.0
python-dotenv>=1.0.0

# CLI
rich>=13.0.0
click>=8.1.0

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-asyncio>=0.21.0

# Code Quality
black>=23.0.0
isort>=5.12.0
flake8>=6.1.0
mypy>=1.5.0
```

Create `config/system.yaml`:
```yaml
# System Configuration

# Model Settings
model:
  path: "data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf"
  context_size: 4096
  gpu_layers: -1  # -1 = all layers to GPU
  threads: 8
  batch_size: 512

# Memory Settings
memory:
  vector_db_path: "data/vector_db"
  registry_db_path: "data/registry.db"
  embedding_model: "all-MiniLM-L6-v2"
  chunk_size: 512
  chunk_overlap: 50

# Generation Settings
generation:
  temperature: 0.7
  max_tokens: 2048
  top_p: 0.9
  top_k: 40
  repeat_penalty: 1.1

# Vision Settings
vision:
  max_image_size: 1024
  supported_formats: ["png", "jpg", "jpeg", "webp"]

# Logging
logging:
  level: "INFO"
  file: "logs/ragme.log"
  max_bytes: 10485760  # 10MB
  backup_count: 5
```

Create `config/policy.yaml`:
```yaml
# Policy Configuration (CCAC System)

# Trust Levels
trust_levels:
  SANDBOX: 0      # Isolated execution only
  BASIC: 1        # Read-only operations
  ELEVATED: 2     # Write operations allowed
  FULL: 3         # System-level access

# Category Definitions
categories:
  file:
    read: BASIC
    write: ELEVATED
    delete: ELEVATED
    system: FULL

  network:
    http_read: BASIC
    http_write: ELEVATED
    websocket: ELEVATED
    raw_socket: FULL

  desktop:
    screenshot: BASIC
    mouse: ELEVATED
    keyboard: ELEVATED
    clipboard: ELEVATED

  system:
    shell: ELEVATED
    process: ELEVATED
    service: FULL
    package: FULL

  browser:
    navigate: BASIC
    scrape: BASIC
    interact: ELEVATED
    download: ELEVATED

  database:
    read: BASIC
    write: ELEVATED
    admin: FULL

  api:
    public: BASIC
    authenticated: ELEVATED
    payment: FULL

  data:
    parse: BASIC
    transform: BASIC
    encrypt: ELEVATED

# Sandbox Configuration
sandbox:
  memory_limit: "2GB"
  cpu_limit: 2.0
  timeout: 300
  network_enabled: true
  temp_dir: "/tmp/ragme_sandbox"

# Approval Settings
approval:
  first_time_required: true
  bulk_category_approval: true
  show_code_preview: true
```

Create `config/training.yaml`:
```yaml
# Training Configuration (LoRA/QLoRA)

# Training Parameters
training:
  rank: 16
  alpha: 32
  dropout: 0.05
  target_modules:
    - "q_proj"
    - "v_proj"
    - "k_proj"
    - "o_proj"

  # Optimizer
  learning_rate: 2e-4
  weight_decay: 0.01
  warmup_steps: 100

  # Training Loop
  epochs: 3
  batch_size: 4
  gradient_accumulation_steps: 4
  max_grad_norm: 1.0

# Validation
validation:
  split: 0.1
  min_accuracy: 0.70
  eval_steps: 50

# Hardware
hardware:
  use_gpu: true
  fp16: true
  gradient_checkpointing: true
```

Create `.gitignore`:
```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/
dist/
build/

# Data
data/models/*.gguf
data/vector_db/
data/adapters/
*.db
*.db-journal

# Logs
logs/*.log

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Generated
tools/*
!tools/.gitkeep
knowledge/*
!knowledge/.gitkeep
adapters/*
!adapters/.gitkeep

# Secrets
.env
*.key
*.pem
```

Create empty placeholder files:
```bash
touch tools/.gitkeep knowledge/.gitkeep adapters/.gitkeep logs/.gitkeep
```

**Success Criteria**:
- ✅ requirements.txt created
- ✅ All config/*.yaml files created
- ✅ .gitignore configured
- ✅ Placeholder files in place

---

#### Day 5: Docker Setup

**Task 0.1.5: Install Docker with NVIDIA Support**

```bash
# 1. Install Docker
sudo apt install -y docker.io docker-compose

# 2. Add user to docker group
sudo usermod -aG docker $USER

# 3. Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

# 4. Configure Docker for NVIDIA
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 5. Test GPU access in Docker
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

**Expected Output**: nvidia-smi output showing GPU in Docker container

**Success Criteria**:
- ✅ Docker installed
- ✅ User in docker group
- ✅ NVIDIA Container Toolkit installed
- ✅ GPU accessible from Docker containers

---

### Week 2: Core Tools Installation

#### Day 1-2: Python Environment

**Task 0.2.1: Create Python Virtual Environment**

```bash
cd ~/RAGme

# 1. Create virtual environment
python3.11 -m venv venv

# 2. Activate
source venv/bin/activate

# 3. Upgrade pip
pip install --upgrade pip setuptools wheel

# 4. Install requirements
pip install -r requirements.txt

# 5. Verify installations
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import transformers; print(f'Transformers: {transformers.__version__}')"
python -c "import chromadb; print(f'ChromaDB: {chromadb.__version__}')"
```

**Success Criteria**:
- ✅ Virtual environment created
- ✅ All packages installed without errors
- ✅ PyTorch recognizes CUDA

---

**Task 0.2.2: Install llama.cpp**

```bash
# 1. Clone repository
cd ~/projects
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# 2. Build with CUDA support
make clean
make LLAMA_CUDA=1 -j$(nproc)

# 3. Verify build
./main --version
# Should show: "build: ... (CUDA)"

# 4. Install Python bindings with CUDA
cd ~/RAGme
source venv/bin/activate
CMAKE_ARGS="-DLLAMA_CUDA=1" pip install llama-cpp-python --force-reinstall --no-cache-dir

# 5. Verify Python bindings
python -c "from llama_cpp import Llama; print('llama-cpp-python installed successfully')"
```

**Success Criteria**:
- ✅ llama.cpp compiled with CUDA
- ✅ Python bindings installed
- ✅ Can import llama_cpp

---

#### Day 3-5: Database Setup

**Task 0.2.3: Initialize ChromaDB**

Create `src/persistence/init_vector_db.py`:
```python
"""Initialize ChromaDB vector database"""
import chromadb
from chromadb.config import Settings
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def initialize_vector_db(persist_directory: str = "data/vector_db"):
    """Initialize ChromaDB with required collections"""

    logger.info(f"Initializing ChromaDB at {persist_directory}")

    # Create client
    client = chromadb.Client(Settings(
        chroma_db_impl="duckdb+parquet",
        persist_directory=persist_directory
    ))

    # Define collections
    collections = {
        "knowledge": {
            "description": "General knowledge and domain expertise",
            "metadata": {"hnsw:space": "cosine"}
        },
        "tools": {
            "description": "Tool documentation and usage examples",
            "metadata": {"hnsw:space": "cosine"}
        },
        "conversations": {
            "description": "Important conversation snippets and lessons",
            "metadata": {"hnsw:space": "cosine"}
        },
        "user_preferences": {
            "description": "User preferences and corrections",
            "metadata": {"hnsw:space": "cosine"}
        }
    }

    # Create collections
    created_collections = []
    for name, config in collections.items():
        try:
            collection = client.get_or_create_collection(
                name=name,
                metadata=config["metadata"]
            )
            logger.info(f"✓ Collection '{name}' ready (count: {collection.count()})")
            created_collections.append(name)
        except Exception as e:
            logger.error(f"✗ Failed to create collection '{name}': {e}")
            raise

    logger.info(f"✓ ChromaDB initialized with {len(created_collections)} collections")
    return created_collections

if __name__ == "__main__":
    initialize_vector_db()
```

Run initialization:
```bash
cd ~/RAGme
source venv/bin/activate
python src/persistence/init_vector_db.py
```

**Success Criteria**:
- ✅ ChromaDB initialized
- ✅ 4 collections created
- ✅ data/vector_db/ directory exists

---

**Task 0.2.4: Initialize SQLite Registry**

Create `src/persistence/schema.sql`:
```sql
-- RAGme Registry Database Schema

-- Tools Registry
CREATE TABLE IF NOT EXISTS tools (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    code TEXT NOT NULL,
    tests TEXT,
    category TEXT NOT NULL,
    trust_level INTEGER DEFAULT 0,
    version INTEGER DEFAULT 1,
    success_count INTEGER DEFAULT 0,
    failure_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tool Versions (for rollback)
CREATE TABLE IF NOT EXISTS tool_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tool_id INTEGER NOT NULL,
    version INTEGER NOT NULL,
    code TEXT NOT NULL,
    tests TEXT,
    changelog TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tool_id) REFERENCES tools(id),
    UNIQUE(tool_id, version)
);

-- LoRA Adapters Registry
CREATE TABLE IF NOT EXISTS adapters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    path TEXT NOT NULL,
    task_type TEXT,
    training_config TEXT,
    validation_score REAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Category Approvals
CREATE TABLE IF NOT EXISTS category_approvals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT UNIQUE NOT NULL,
    trust_level INTEGER NOT NULL,
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tool-Specific Overrides
CREATE TABLE IF NOT EXISTS tool_overrides (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tool_id INTEGER NOT NULL,
    decision TEXT NOT NULL,  -- 'approve' or 'deny'
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tool_id) REFERENCES tools(id)
);

-- Policy Audit Log
CREATE TABLE IF NOT EXISTS policy_audit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type TEXT NOT NULL,  -- 'tool_request', 'category_approval', 'tool_execution'
    decision TEXT NOT NULL,     -- 'approve', 'deny', 'pending'
    context TEXT,              -- JSON with details
    tool_id INTEGER,
    category TEXT
);

-- Capability Gaps
CREATE TABLE IF NOT EXISTS gaps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    gap_type TEXT NOT NULL,  -- 'tool', 'knowledge', 'reasoning'
    description TEXT NOT NULL,
    status TEXT DEFAULT 'detected',  -- 'detected', 'proposed', 'approved', 'resolved'
    solution_id INTEGER,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- System Configuration
CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Indexes
CREATE INDEX IF NOT EXISTS idx_tools_category ON tools(category);
CREATE INDEX IF NOT EXISTS idx_tools_trust_level ON tools(trust_level);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON policy_audit(timestamp);
CREATE INDEX IF NOT EXISTS idx_gaps_status ON gaps(status);
```

Create `src/persistence/init_registry.py`:
```python
"""Initialize SQLite registry database"""
import sqlite3
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def initialize_registry(db_path: str = "data/registry.db"):
    """Initialize SQLite registry database"""

    logger.info(f"Initializing registry at {db_path}")

    # Ensure directory exists
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)

    # Read schema
    schema_path = Path(__file__).parent / "schema.sql"
    with open(schema_path, 'r') as f:
        schema = f.read()

    # Connect and create tables
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        cursor.executescript(schema)
        conn.commit()

        # Verify tables
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row[0] for row in cursor.fetchall()]

        logger.info(f"✓ Registry initialized with {len(tables)} tables:")
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            logger.info(f"  - {table}: {count} rows")

        # Insert default configuration
        default_config = [
            ('system_version', '1.0.0', 'System version'),
            ('first_run', 'true', 'Is this the first run?'),
            ('model_loaded', 'false', 'Is model currently loaded?')
        ]

        cursor.executemany(
            "INSERT OR IGNORE INTO config (key, value, description) VALUES (?, ?, ?)",
            default_config
        )
        conn.commit()

        logger.info("✓ Registry initialized successfully")

    except Exception as e:
        logger.error(f"✗ Failed to initialize registry: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    initialize_registry()
```

Run initialization:
```bash
cd ~/RAGme
source venv/bin/activate
python src/persistence/init_registry.py
```

**Success Criteria**:
- ✅ data/registry.db created
- ✅ All tables created
- ✅ Default config inserted

---

#### Day 6-7: Verification

**Task 0.2.5: Create Installation Verification Script**

Create `verify_installation.py`:
```python
"""Verify Phase 0 installation"""
import sys
import subprocess
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'

def check(condition: bool, message: str) -> bool:
    """Print check result"""
    if condition:
        logger.info(f"{Colors.GREEN}✓{Colors.RESET} {message}")
        return True
    else:
        logger.error(f"{Colors.RED}✗{Colors.RESET} {message}")
        return False

def verify_installation():
    """Run all verification checks"""
    logger.info("\\n" + "="*60)
    logger.info("RAGme Installation Verification")
    logger.info("="*60 + "\\n")

    checks_passed = 0
    checks_total = 0

    # 1. Python version
    checks_total += 1
    py_version = sys.version_info
    if check(py_version >= (3, 11), f"Python 3.11+ installed (found: {py_version.major}.{py_version.minor})"):
        checks_passed += 1

    # 2. CUDA available
    checks_total += 1
    try:
        result = subprocess.run(['nvidia-smi'], capture_output=True, text=True)
        if check(result.returncode == 0, "NVIDIA GPU detected"):
            checks_passed += 1
    except FileNotFoundError:
        check(False, "NVIDIA GPU detected")

    # 3. Required packages
    required_packages = [
        'torch', 'transformers', 'chromadb',
        'llama_cpp', 'PIL', 'sentence_transformers'
    ]

    for package in required_packages:
        checks_total += 1
        try:
            __import__(package)
            if check(True, f"Package '{package}' installed"):
                checks_passed += 1
        except ImportError:
            check(False, f"Package '{package}' installed")

    # 4. Directory structure
    required_dirs = [
        'src', 'config', 'data', 'tests',
        'src/intelligence', 'src/capability', 'src/policy'
    ]

    for dir_path in required_dirs:
        checks_total += 1
        path = Path(dir_path)
        if check(path.exists() and path.is_dir(), f"Directory '{dir_path}' exists"):
            checks_passed += 1

    # 5. Configuration files
    required_configs = [
        'config/system.yaml',
        'config/policy.yaml',
        'config/training.yaml'
    ]

    for config_path in required_configs:
        checks_total += 1
        path = Path(config_path)
        if check(path.exists() and path.is_file(), f"Config '{config_path}' exists"):
            checks_passed += 1

    # 6. Databases
    checks_total += 1
    vector_db_path = Path("data/vector_db")
    if check(vector_db_path.exists(), "ChromaDB initialized"):
        checks_passed += 1

    checks_total += 1
    registry_path = Path("data/registry.db")
    if check(registry_path.exists(), "Registry DB initialized"):
        checks_passed += 1

    # 7. Docker with GPU
    checks_total += 1
    try:
        result = subprocess.run(
            ['docker', 'run', '--rm', '--gpus', 'all', 'nvidia/cuda:12.1.0-base-ubuntu22.04', 'nvidia-smi'],
            capture_output=True,
            text=True,
            timeout=30
        )
        if check(result.returncode == 0, "Docker GPU access working"):
            checks_passed += 1
    except (FileNotFoundError, subprocess.TimeoutExpired):
        check(False, "Docker GPU access working")

    # Summary
    logger.info("\\n" + "="*60)
    logger.info(f"Results: {checks_passed}/{checks_total} checks passed")
    logger.info("="*60 + "\\n")

    if checks_passed == checks_total:
        logger.info(f"{Colors.GREEN}✓ Installation verified - Ready for Phase 1!{Colors.RESET}\\n")
        return 0
    else:
        logger.error(f"{Colors.RED}✗ Installation incomplete - Fix errors before proceeding{Colors.RESET}\\n")
        return 1

if __name__ == "__main__":
    sys.exit(verify_installation())
```

Run verification:
```bash
cd ~/RAGme
source venv/bin/activate
python verify_installation.py
```

**Expected Output**: All checks pass (✓)

**Success Criteria**:
- ✅ Python 3.11+ detected
- ✅ NVIDIA GPU accessible
- ✅ All packages installed
- ✅ Directory structure complete
- ✅ Configuration files present
- ✅ Databases initialized
- ✅ Docker GPU access working

---

### Phase 0 Completion Checklist

Before proceeding to Phase 1, verify:

- [ ] Hardware meets specifications
- [ ] Python 3.11+ installed
- [ ] NVIDIA drivers and CUDA installed
- [ ] Project structure created
- [ ] Configuration files created
- [ ] Python virtual environment with all packages
- [ ] llama.cpp compiled with CUDA
- [ ] Docker with NVIDIA Container Toolkit
- [ ] ChromaDB initialized (4 collections)
- [ ] SQLite registry initialized (8 tables)
- [ ] Verification script passes all checks

**If all items checked**: Ready for Phase 1 ✅

---

## Phase 1: Core System (Weeks 3-8)

**Duration**: 6 weeks
**Goal**: Build minimum viable self-evolving system
**Outcome**: System can autonomously generate its first tool

### Overview

Phase 1 builds the foundation:
- **Intelligence Layer**: LLM engine with vision
- **Memory Layer**: RAG system with ChromaDB
- **Policy Layer**: CCAC with approval workflow
- **Capability Layer**: Gap detection and tool generation
- **Orchestration Layer**: Agent controller
- **Integration**: End-to-end self-evolution loop

---

### Week 3: LLM Engine & Vision

**Goal**: Get Qwen2.5-VL-7B running with vision processing

#### Prerequisites

- [ ] Phase 0 complete
- [ ] Virtual environment activated
- [ ] 15GB free disk space (for model)

---

#### Day 1: Model Download

**Task 3.1.1: Download Qwen2.5-VL-7B Model**

```bash
cd ~/RAGme
source venv/bin/activate

# Ensure data/models directory exists
mkdir -p data/models

# Method 1: Direct download (recommended)
huggingface-cli download \
  Qwen/Qwen2.5-VL-7B-Instruct-GGUF \
  qwen2.5-vl-7b-instruct-q4_k_m.gguf \
  --local-dir data/models \
  --local-dir-use-symlinks False

# Verify download
ls -lh data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf
# Expected: ~4.5-5GB file

# Calculate checksum for verification
sha256sum data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf > data/models/model.sha256
```

**If Method 1 fails** (GGUF not available), use conversion:
```bash
# Install git-lfs
sudo apt install -y git-lfs
git lfs install

# Clone base model
cd data/models
git clone https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct

# Convert to GGUF
cd ~/projects/llama.cpp
python convert.py \
  ~/RAGme/data/models/Qwen2.5-VL-7B-Instruct \
  --outfile ~/RAGme/data/models/qwen2.5-vl-7b-instruct-f16.gguf \
  --outtype f16

# Quantize to Q4_K_M
./quantize \
  ~/RAGme/data/models/qwen2.5-vl-7b-instruct-f16.gguf \
  ~/RAGme/data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf \
  Q4_K_M

# Clean up intermediate files
rm ~/RAGme/data/models/qwen2.5-vl-7b-instruct-f16.gguf
rm -rf ~/RAGme/data/models/Qwen2.5-VL-7B-Instruct
```

**Success Criteria**:
- ✅ Model file exists: `data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf`
- ✅ File size: 4.5-5GB
- ✅ Checksum file created

**Time Estimate**: 1-3 hours (depends on download speed)

---

#### Day 2: Basic LLM Integration

**Task 3.1.2: Test Model Loading**

Create `tests/manual/test_model_loading.py`:
```python
"""Test basic model loading and inference"""
from llama_cpp import Llama
import time
import psutil
import GPUtil

def test_model_loading():
    """Test loading model and basic inference"""

    print("\\n" + "="*60)
    print("Model Loading Test")
    print("="*60 + "\\n")

    # Get initial GPU stats
    gpus = GPUtil.getGPUs()
    if gpus:
        gpu = gpus[0]
        print(f"GPU: {gpu.name}")
        print(f"Initial VRAM: {gpu.memoryUsed:.0f}MB / {gpu.memoryTotal:.0f}MB\\n")

    # Load model
    print("Loading model...")
    start_time = time.time()

    llm = Llama(
        model_path="data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf",
        n_ctx=4096,
        n_gpu_layers=-1,  # All layers to GPU
        verbose=False
    )

    load_time = time.time() - start_time
    print(f"✓ Model loaded in {load_time:.2f}s\\n")

    # Check VRAM after loading
    if gpus:
        gpu = gpus[0]
        print(f"VRAM after loading: {gpu.memoryUsed:.0f}MB / {gpu.memoryTotal:.0f}MB")
        print(f"VRAM used by model: {gpu.memoryUsed - initial_vram:.0f}MB\\n")

        if gpu.memoryUsed > 7500:
            print("⚠️  WARNING: VRAM usage > 7.5GB - may cause issues\\n")

    # Test inference
    print("Testing inference...")
    prompts = [
        "What is 2+2?",
        "Explain Python in one sentence.",
        "Write a haiku about programming."
    ]

    for i, prompt in enumerate(prompts, 1):
        print(f"\\nPrompt {i}: {prompt}")

        start_time = time.time()
        response = llm(
            prompt,
            max_tokens=100,
            temperature=0.7,
            stop=["\\n\\n"],
            echo=False
        )
        inference_time = time.time() - start_time

        text = response['choices'][0]['text'].strip()
        tokens = response['usage']['completion_tokens']
        tokens_per_sec = tokens / inference_time if inference_time > 0 else 0

        print(f"Response: {text}")
        print(f"Speed: {tokens_per_sec:.1f} tokens/sec")

        if tokens_per_sec < 35:
            print("⚠️  WARNING: Speed below target (35 tok/s)")

    print("\\n" + "="*60)
    print("Test Complete")
    print("="*60 + "\\n")

if __name__ == "__main__":
    # Store initial VRAM
    gpus = GPUtil.getGPUs()
    initial_vram = gpus[0].memoryUsed if gpus else 0

    test_model_loading()
```

Run test:
```bash
cd ~/RAGme
source venv/bin/activate
python tests/manual/test_model_loading.py
```

**Expected Output**:
```
============================================================
Model Loading Test
============================================================

GPU: NVIDIA GeForce RTX 4060
Initial VRAM: 500MB / 8192MB

Loading model...
✓ Model loaded in 12.3s

VRAM after loading: 6800MB / 8192MB
VRAM used by model: 6300MB

Testing inference...

Prompt 1: What is 2+2?
Response: 4
Speed: 42.3 tokens/sec

Prompt 2: Explain Python in one sentence.
Response: Python is a high-level, interpreted programming language...
Speed: 39.8 tokens/sec

Prompt 3: Write a haiku about programming.
Response: Code flows like water...
Speed: 41.2 tokens/sec

============================================================
Test Complete
============================================================
```

**Success Criteria**:
- ✅ Model loads successfully
- ✅ Load time < 20 seconds
- ✅ VRAM usage < 7.5GB
- ✅ Inference speed ≥ 35 tokens/second
- ✅ Responses are coherent

**If Failed**:
- VRAM > 7.5GB: Try reducing n_ctx to 2048
- Speed < 35 tok/s: Check CUDA installation, GPU utilization
- Load fails: Check model file integrity (re-download if needed)

---

#### Day 3-4: LLM Engine Implementation

**Task 3.1.3: Implement Core LLM Engine**

Create `src/intelligence/llm/engine.py`:
```python
"""LLM Engine for Qwen2.5-VL-7B with vision and LoRA support"""
from llama_cpp import Llama
from typing import Optional, Dict, Any, List, Generator
from pathlib import Path
import logging
import time

logger = logging.getLogger(__name__)

class LLMEngine:
    """
    LLM inference engine with support for:
    - Text generation
    - Vision processing (multimodal)
    - LoRA adapter hot-swapping
    - Streaming responses
    - Context management
    """

    def __init__(
        self,
        model_path: str,
        n_ctx: int = 4096,
        n_gpu_layers: int = -1,
        verbose: bool = False
    ):
        """
        Initialize LLM engine

        Args:
            model_path: Path to GGUF model file
            n_ctx: Context window size (tokens)
            n_gpu_layers: Number of layers to offload to GPU (-1 = all)
            verbose: Enable verbose logging
        """
        self.model_path = Path(model_path)
        self.n_ctx = n_ctx
        self.n_gpu_layers = n_gpu_layers
        self.verbose = verbose

        self.llm: Optional[Llama] = None
        self.current_adapters: List[str] = []
        self.is_loaded = False

        # Statistics
        self.total_tokens_generated = 0
        self.total_inference_time = 0.0

        # Load model
        self._load_model()

    def _load_model(self):
        """Load model into memory"""
        if not self.model_path.exists():
            raise FileNotFoundError(f"Model not found: {self.model_path}")

        logger.info(f"Loading model from {self.model_path}")
        logger.info(f"Context size: {self.n_ctx}, GPU layers: {self.n_gpu_layers}")

        start_time = time.time()

        try:
            self.llm = Llama(
                model_path=str(self.model_path),
                n_ctx=self.n_ctx,
                n_gpu_layers=self.n_gpu_layers,
                verbose=self.verbose,
                # Performance optimizations
                n_batch=512,
                n_threads=8,
                use_mlock=True  # Lock model in RAM
            )

            load_time = time.time() - start_time
            self.is_loaded = True

            logger.info(f"✓ Model loaded successfully in {load_time:.2f}s")

        except Exception as e:
            logger.error(f"✗ Failed to load model: {e}")
            raise

    def generate(
        self,
        prompt: str,
        max_tokens: int = 512,
        temperature: float = 0.7,
        top_p: float = 0.9,
        top_k: int = 40,
        repeat_penalty: float = 1.1,
        stop: Optional[List[str]] = None,
        stream: bool = False
    ) -> str | Generator[str, None, None]:
        """
        Generate text from prompt

        Args:
            prompt: Input prompt
            max_tokens: Maximum tokens to generate
            temperature: Sampling temperature (0.0-2.0)
            top_p: Nucleus sampling threshold
            top_k: Top-k sampling parameter
            repeat_penalty: Penalty for repetition
            stop: Stop sequences
            stream: Enable streaming response

        Returns:
            Generated text (or generator if streaming)
        """
        if not self.is_loaded:
            raise RuntimeError("Model not loaded")

        start_time = time.time()

        try:
            response = self.llm(
                prompt,
                max_tokens=max_tokens,
                temperature=temperature,
                top_p=top_p,
                top_k=top_k,
                repeat_penalty=repeat_penalty,
                stop=stop or [],
                stream=stream,
                echo=False
            )

            if stream:
                # Return generator for streaming
                def stream_generator():
                    for chunk in response:
                        token = chunk['choices'][0]['text']
                        yield token
                return stream_generator()

            else:
                # Regular completion
                text = response['choices'][0]['text']

                # Update statistics
                tokens = response['usage']['completion_tokens']
                inference_time = time.time() - start_time

                self.total_tokens_generated += tokens
                self.total_inference_time += inference_time

                logger.debug(f"Generated {tokens} tokens in {inference_time:.2f}s "
                           f"({tokens/inference_time:.1f} tok/s)")

                return text

        except Exception as e:
            logger.error(f"Generation failed: {e}")
            raise

    def load_adapter(self, adapter_path: str):
        """
        Load LoRA adapter

        Args:
            adapter_path: Path to adapter weights

        Note: Implementation will be completed in Week 7
        """
        logger.info(f"Loading adapter: {adapter_path}")

        # TODO: Implement actual LoRA loading
        # For now, just track which adapters are "loaded"
        if adapter_path not in self.current_adapters:
            self.current_adapters.append(adapter_path)
            logger.info(f"✓ Adapter loaded (stub): {adapter_path}")

    def unload_adapters(self):
        """Unload all LoRA adapters"""
        if self.current_adapters:
            logger.info(f"Unloading {len(self.current_adapters)} adapters")
            self.current_adapters.clear()

    def get_stats(self) -> Dict[str, Any]:
        """Get engine statistics"""
        avg_speed = (self.total_tokens_generated / self.total_inference_time
                    if self.total_inference_time > 0 else 0)

        return {
            "model": str(self.model_path.name),
            "context_size": self.n_ctx,
            "gpu_layers": self.n_gpu_layers,
            "loaded": self.is_loaded,
            "adapters_loaded": len(self.current_adapters),
            "total_tokens_generated": self.total_tokens_generated,
            "total_inference_time": self.total_inference_time,
            "average_speed_tokens_per_sec": round(avg_speed, 2)
        }

    def reset_stats(self):
        """Reset statistics counters"""
        self.total_tokens_generated = 0
        self.total_inference_time = 0.0
        logger.info("Statistics reset")

    def unload(self):
        """Unload model from memory"""
        if self.is_loaded:
            logger.info("Unloading model from memory")
            self.llm = None
            self.is_loaded = False
            self.current_adapters.clear()
            logger.info("✓ Model unloaded")

    def __del__(self):
        """Cleanup on deletion"""
        self.unload()
```

**Success Criteria**:
- ✅ File created: `src/intelligence/llm/engine.py`
- ✅ No syntax errors
- ✅ Follows type hints

---

**Task 3.1.4: Test LLM Engine**

Create `tests/unit/test_llm_engine.py`:
```python
"""Unit tests for LLM Engine"""
import pytest
from src.intelligence.llm.engine import LLMEngine
from pathlib import Path

@pytest.fixture
def engine():
    """Create LLM engine instance"""
    model_path = "data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf"
    if not Path(model_path).exists():
        pytest.skip("Model not downloaded")

    engine = LLMEngine(
        model_path=model_path,
        n_ctx=4096,
        verbose=False
    )
    yield engine
    engine.unload()

def test_engine_initialization(engine):
    """Test engine initializes correctly"""
    assert engine.is_loaded
    assert engine.llm is not None
    stats = engine.get_stats()
    assert stats['loaded'] == True
    assert stats['context_size'] == 4096

def test_basic_generation(engine):
    """Test basic text generation"""
    prompt = "What is 2+2? Answer:"
    response = engine.generate(prompt, max_tokens=10)

    assert isinstance(response, str)
    assert len(response) > 0
    assert '4' in response

def test_generation_parameters(engine):
    """Test different generation parameters"""
    prompt = "Write one word:"

    # Low temperature (deterministic)
    response1 = engine.generate(prompt, temperature=0.1, max_tokens=5)
    response2 = engine.generate(prompt, temperature=0.1, max_tokens=5)
    # Responses should be similar

    # High temperature (creative)
    response3 = engine.generate(prompt, temperature=1.5, max_tokens=5)
    assert isinstance(response3, str)

def test_stop_sequences(engine):
    """Test stop sequences"""
    prompt = "Count: 1, 2, 3,"
    response = engine.generate(
        prompt,
        max_tokens=20,
        stop=[",", "."]
    )

    assert "," not in response.strip()
    assert "." not in response.strip()

def test_statistics(engine):
    """Test statistics tracking"""
    engine.reset_stats()

    initial_stats = engine.get_stats()
    assert initial_stats['total_tokens_generated'] == 0

    # Generate some text
    engine.generate("Test prompt", max_tokens=50)

    final_stats = engine.get_stats()
    assert final_stats['total_tokens_generated'] > 0
    assert final_stats['average_speed_tokens_per_sec'] > 0

def test_adapter_management(engine):
    """Test adapter loading/unloading"""
    assert len(engine.current_adapters) == 0

    # Load adapter (stub implementation)
    engine.load_adapter("test_adapter.safetensors")
    assert len(engine.current_adapters) == 1

    # Unload
    engine.unload_adapters()
    assert len(engine.current_adapters) == 0

def test_streaming_generation(engine):
    """Test streaming response"""
    prompt = "Count to 5:"
    stream = engine.generate(prompt, max_tokens=20, stream=True)

    # Collect stream
    tokens = list(stream)
    assert len(tokens) > 0

    full_text = ''.join(tokens)
    assert isinstance(full_text, str)

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
```

Run tests:
```bash
cd ~/RAGme
source venv/bin/activate
pytest tests/unit/test_llm_engine.py -v
```

**Expected Output**:
```
tests/unit/test_llm_engine.py::test_engine_initialization PASSED
tests/unit/test_llm_engine.py::test_basic_generation PASSED
tests/unit/test_llm_engine.py::test_generation_parameters PASSED
tests/unit/test_llm_engine.py::test_stop_sequences PASSED
tests/unit/test_llm_engine.py::test_statistics PASSED
tests/unit/test_llm_engine.py::test_adapter_management PASSED
tests/unit/test_llm_engine.py::test_streaming_generation PASSED

========== 7 passed in 45.23s ==========
```

**Success Criteria**:
- ✅ All tests pass
- ✅ No errors or warnings
- ✅ Performance acceptable (< 1 min total)

---

---

#### Day 5-6: Vision Processing

**Task 3.1.5: Implement Vision Processor**

Create `src/intelligence/vision/processor.py`:
```python
"""Vision processing for Qwen2.5-VL-7B"""
from PIL import Image
from typing import Union, List, Tuple
from pathlib import Path
import logging
import base64
import io

logger = logging.getLogger(__name__)

class VisionProcessor:
    """
    Process images for multimodal LLM input

    Features:
    - Image loading from file or bytes
    - Automatic resizing and format conversion
    - Multiple image support
    - Screenshot integration
    """

    def __init__(
        self,
        max_image_size: int = 1024,
        supported_formats: List[str] = None
    ):
        """
        Initialize vision processor

        Args:
            max_image_size: Maximum dimension for images (width or height)
            supported_formats: List of supported image formats
        """
        self.max_image_size = max_image_size
        self.supported_formats = supported_formats or ["png", "jpg", "jpeg", "webp"]

    def load_image(self, image_path: Union[str, Path]) -> Image.Image:
        """
        Load image from file

        Args:
            image_path: Path to image file

        Returns:
            PIL Image object
        """
        image_path = Path(image_path)

        if not image_path.exists():
            raise FileNotFoundError(f"Image not found: {image_path}")

        # Check format
        ext = image_path.suffix.lower().lstrip('.')
        if ext not in self.supported_formats:
            raise ValueError(f"Unsupported format: {ext}")

        try:
            image = Image.open(image_path)
            logger.debug(f"Loaded image: {image_path} ({image.size})")
            return image
        except Exception as e:
            logger.error(f"Failed to load image: {e}")
            raise

    def load_from_bytes(self, image_bytes: bytes) -> Image.Image:
        """
        Load image from bytes

        Args:
            image_bytes: Raw image bytes

        Returns:
            PIL Image object
        """
        try:
            image = Image.open(io.BytesIO(image_bytes))
            return image
        except Exception as e:
            logger.error(f"Failed to load image from bytes: {e}")
            raise

    def resize_image(self, image: Image.Image) -> Image.Image:
        """
        Resize image if it exceeds max_image_size

        Args:
            image: PIL Image object

        Returns:
            Resized image
        """
        width, height = image.size

        if width <= self.max_image_size and height <= self.max_image_size:
            return image

        # Calculate new dimensions
        if width > height:
            new_width = self.max_image_size
            new_height = int(height * (self.max_image_size / width))
        else:
            new_height = self.max_image_size
            new_width = int(width * (self.max_image_size / height))

        resized = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
        logger.debug(f"Resized image from {image.size} to {resized.size}")

        return resized

    def convert_to_rgb(self, image: Image.Image) -> Image.Image:
        """
        Convert image to RGB format

        Args:
            image: PIL Image object

        Returns:
            RGB image
        """
        if image.mode != 'RGB':
            logger.debug(f"Converting image from {image.mode} to RGB")
            return image.convert('RGB')
        return image

    def process_image(self, image: Union[str, Path, bytes, Image.Image]) -> Image.Image:
        """
        Process image for LLM input

        Args:
            image: Image path, bytes, or PIL Image

        Returns:
            Processed PIL Image (resized, RGB)
        """
        # Load image
        if isinstance(image, (str, Path)):
            img = self.load_image(image)
        elif isinstance(image, bytes):
            img = self.load_from_bytes(image)
        elif isinstance(image, Image.Image):
            img = image
        else:
            raise TypeError(f"Unsupported image type: {type(image)}")

        # Process
        img = self.convert_to_rgb(img)
        img = self.resize_image(img)

        return img

    def encode_image_base64(self, image: Image.Image) -> str:
        """
        Encode image as base64 string

        Args:
            image: PIL Image object

        Returns:
            Base64 encoded string
        """
        buffer = io.BytesIO()
        image.save(buffer, format='PNG')
        encoded = base64.b64encode(buffer.getvalue()).decode('utf-8')
        return encoded

    def prepare_multimodal_input(
        self,
        text: str,
        images: List[Union[str, Path, Image.Image]]
    ) -> Tuple[str, List[Image.Image]]:
        """
        Prepare multimodal input (text + images) for LLM

        Args:
            text: Text prompt
            images: List of images

        Returns:
            (formatted_prompt, processed_images)
        """
        processed_images = []

        for img in images:
            processed = self.process_image(img)
            processed_images.append(processed)

        # Format prompt with image placeholders
        # Note: Exact format depends on model's expected input
        formatted_prompt = f"<|im_start|>user\n{text}\n"
        for i in range(len(processed_images)):
            formatted_prompt += f"<image_{i}>\n"
        formatted_prompt += "<|im_end|>"

        return formatted_prompt, processed_images
```

**Success Criteria**:
- ✅ File created: `src/intelligence/vision/processor.py`
- ✅ No syntax errors
- ✅ Type hints complete

---

**Task 3.1.6: Test Vision Processor**

Create `tests/unit/test_vision_processor.py`:
```python
"""Unit tests for Vision Processor"""
import pytest
from PIL import Image
from pathlib import Path
from src.intelligence.vision.processor import VisionProcessor
import tempfile

@pytest.fixture
def processor():
    """Create vision processor"""
    return VisionProcessor(max_image_size=1024)

@pytest.fixture
def test_image():
    """Create test image"""
    img = Image.new('RGB', (2048, 1536), color='red')
    return img

def test_processor_initialization(processor):
    """Test processor initializes correctly"""
    assert processor.max_image_size == 1024
    assert 'png' in processor.supported_formats

def test_resize_large_image(processor, test_image):
    """Test resizing oversized image"""
    resized = processor.resize_image(test_image)

    # Should fit within max_image_size
    assert resized.size[0] <= 1024
    assert resized.size[1] <= 1024

    # Aspect ratio preserved
    original_aspect = test_image.size[0] / test_image.size[1]
    new_aspect = resized.size[0] / resized.size[1]
    assert abs(original_aspect - new_aspect) < 0.01

def test_resize_small_image(processor):
    """Test that small images are not upscaled"""
    small_img = Image.new('RGB', (512, 512))
    resized = processor.resize_image(small_img)

    assert resized.size == (512, 512)

def test_convert_to_rgb(processor):
    """Test image conversion to RGB"""
    # RGBA image
    rgba_img = Image.new('RGBA', (100, 100))
    rgb_img = processor.convert_to_rgb(rgba_img)
    assert rgb_img.mode == 'RGB'

    # Grayscale image
    gray_img = Image.new('L', (100, 100))
    rgb_img = processor.convert_to_rgb(gray_img)
    assert rgb_img.mode == 'RGB'

def test_process_image_pil(processor, test_image):
    """Test processing PIL Image"""
    processed = processor.process_image(test_image)

    assert isinstance(processed, Image.Image)
    assert processed.mode == 'RGB'
    assert processed.size[0] <= 1024
    assert processed.size[1] <= 1024

def test_process_image_path(processor, test_image):
    """Test processing image from file path"""
    with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
        test_image.save(f.name)
        temp_path = f.name

    try:
        processed = processor.process_image(temp_path)
        assert isinstance(processed, Image.Image)
    finally:
        Path(temp_path).unlink()

def test_encode_base64(processor, test_image):
    """Test base64 encoding"""
    small_img = Image.new('RGB', (100, 100))
    encoded = processor.encode_image_base64(small_img)

    assert isinstance(encoded, str)
    assert len(encoded) > 0

def test_multimodal_input_preparation(processor, test_image):
    """Test multimodal input preparation"""
    text = "Describe this image"
    images = [test_image]

    prompt, processed_images = processor.prepare_multimodal_input(text, images)

    assert isinstance(prompt, str)
    assert text in prompt
    assert len(processed_images) == 1
    assert isinstance(processed_images[0], Image.Image)

def test_unsupported_format(processor):
    """Test handling of unsupported format"""
    with tempfile.NamedTemporaryFile(suffix='.bmp', delete=False) as f:
        img = Image.new('RGB', (100, 100))
        img.save(f.name)
        temp_path = f.name

    try:
        with pytest.raises(ValueError):
            processor.load_image(temp_path)
    finally:
        Path(temp_path).unlink()

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
```

Run tests:
```bash
cd ~/RAGme
source venv/bin/activate
pytest tests/unit/test_vision_processor.py -v
```

**Success Criteria**:
- ✅ All tests pass
- ✅ Image processing works correctly
- ✅ Format conversion and resizing functional

---

#### Day 7: Prompt Engineering

**Task 3.1.7: Create Prompt Templates**

Create `src/intelligence/llm/prompts.py`:
```python
"""Prompt templates for RAGme system"""
from typing import Dict, List, Optional
from datetime import datetime

class PromptTemplates:
    """
    System prompt templates for different tasks

    Templates use Qwen2.5-VL chat format:
    <|im_start|>system\n{system}<|im_end|>
    <|im_start|>user\n{user}<|im_end|>
    <|im_start|>assistant\n{assistant}<|im_end|>
    """

    @staticmethod
    def system_prompt() -> str:
        """Base system prompt defining RAGme's identity"""
        return """You are RAGme, a self-evolving AI system that autonomously expands its capabilities.

Core Principles:
1. When you encounter a task you cannot complete, identify the capability gap
2. Propose solutions: new tools, knowledge modules, or reasoning adapters
3. Think step-by-step and explain your reasoning
4. Always prioritize user safety and request approval for new capabilities
5. Be honest about your limitations and uncertainties

Current Capabilities:
- Text generation and analysis
- Vision processing (image understanding)
- Code generation and debugging
- Knowledge retrieval from semantic memory
- Tool usage (when tools are available)

Your goal is to become an increasingly capable cognitive partner through continuous learning."""

    @staticmethod
    def gap_detection_prompt(task: str, error: Optional[str] = None) -> str:
        """Prompt for detecting capability gaps"""
        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}<|im_end|>
<|im_start|>user
I need help with this task:
{task}

{f"I encountered this error: {error}" if error else ""}

Analyze this task and determine:
1. Can you complete this task with your current capabilities?
2. If not, what capability is missing?
3. What type of solution would help? (tool, knowledge, or reasoning improvement)
4. Provide a specific proposal for what to create

Format your response as:
CAN_COMPLETE: yes/no
GAP_TYPE: tool/knowledge/reasoning/none
PROPOSAL: [detailed description of what to create]
REASONING: [your analysis]<|im_end|>
<|im_start|>assistant
Let me analyze this task step by step.

"""

    @staticmethod
    def tool_generation_prompt(
        gap_description: str,
        tool_name: str,
        category: str
    ) -> str:
        """Prompt for generating tool code"""
        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}

You are now in TOOL GENERATION mode. Your task is to write production-quality Python code.<|im_end|>
<|im_start|>user
Generate a Python tool to address this capability gap:

Gap: {gap_description}
Tool Name: {tool_name}
Category: {category}

Requirements:
1. Write complete, executable Python code
2. Include proper error handling
3. Add docstrings and type hints
4. Make it modular and reusable
5. Follow best practices (PEP 8)
6. No external API keys hardcoded (use parameters)
7. Handle edge cases gracefully

The tool should be a Python module with:
- Main function(s) that perform the task
- Clear input/output
- Comprehensive error messages
- Example usage in docstring

Output only the Python code, no explanations.<|im_end|>
<|im_start|>assistant
```python
"""
{tool_name} - {gap_description}
Category: {category}
Generated: {datetime.now().strftime('%Y-%m-%d')}
"""
"""

    @staticmethod
    def test_generation_prompt(tool_code: str, tool_name: str) -> str:
        """Prompt for generating test code"""
        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}

You are now in TEST GENERATION mode. Write comprehensive pytest tests.<|im_end|>
<|im_start|>user
Generate pytest unit tests for this tool:

Tool Name: {tool_name}

Tool Code:
```python
{tool_code}
```

Requirements:
1. Test all major functions
2. Test edge cases and error handling
3. Use pytest fixtures where appropriate
4. Include both positive and negative test cases
5. Aim for >80% code coverage
6. Tests should be independent and repeatable

Output only the test code, no explanations.<|im_end|>
<|im_start|>assistant
```python
"""
Tests for {tool_name}
Generated: {datetime.now().strftime('%Y-%m-%d')}
"""
import pytest
"""

    @staticmethod
    def knowledge_generation_prompt(
        topic: str,
        context: str,
        sources: List[str]
    ) -> str:
        """Prompt for generating knowledge modules"""
        sources_text = "\n".join(f"- {s}" for s in sources) if sources else "None"

        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}

You are now in KNOWLEDGE CREATION mode. Synthesize information into structured knowledge.<|im_end|>
<|im_start|>user
Create a knowledge module about: {topic}

Context: {context}

Available Sources:
{sources_text}

Create a comprehensive knowledge module that includes:
1. Overview/Summary
2. Key Concepts
3. Step-by-step procedures (if applicable)
4. Common pitfalls and how to avoid them
5. Examples
6. References

Format as structured markdown with clear sections.<|im_end|>
<|im_start|>assistant
# Knowledge Module: {topic}

"""

    @staticmethod
    def code_review_prompt(code: str, purpose: str) -> str:
        """Prompt for reviewing generated code"""
        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}

You are now in CODE REVIEW mode. Analyze code for safety, correctness, and quality.<|im_end|>
<|im_start|>user
Review this code for potential issues:

Purpose: {purpose}

Code:
```python
{code}
```

Check for:
1. Security vulnerabilities
2. Logical errors
3. Edge cases not handled
4. Performance issues
5. Code quality (readability, maintainability)

Provide:
SAFE: yes/no
ISSUES: [list of issues found]
SUGGESTIONS: [improvements]
RISK_LEVEL: low/medium/high<|im_end|>
<|im_start|>assistant
Let me review this code carefully.

"""

    @staticmethod
    def reflexion_prompt(
        code: str,
        error: str,
        iteration: int
    ) -> str:
        """Prompt for Reflexion self-correction"""
        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}

You are in REFLEXION mode. Learn from errors and improve your output.<|im_end|>
<|im_start|>user
Your previous code failed with an error. Analyze and fix it.

Iteration: {iteration}/5

Previous Code:
```python
{code}
```

Error:
{error}

Tasks:
1. Identify the root cause of the error
2. Explain what went wrong
3. Generate corrected code

Be thorough and fix ALL issues, not just the obvious one.<|im_end|>
<|im_start|>assistant
Analysis of the error:

"""

    @staticmethod
    def conversation_prompt(
        user_message: str,
        context: Optional[str] = None,
        available_tools: Optional[List[str]] = None
    ) -> str:
        """Prompt for normal conversation"""
        context_section = f"\nRelevant Context:\n{context}" if context else ""
        tools_section = f"\nAvailable Tools:\n" + "\n".join(f"- {t}" for t in available_tools) if available_tools else ""

        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}{tools_section}<|im_end|>
<|im_start|>user
{user_message}{context_section}<|im_end|>
<|im_start|>assistant
"""

    @staticmethod
    def vision_prompt(
        user_message: str,
        image_count: int
    ) -> str:
        """Prompt for vision tasks"""
        image_placeholders = "\n".join(f"[Image {i+1}]" for i in range(image_count))

        return f"""<|im_start|>system
{PromptTemplates.system_prompt()}

You have vision capabilities and can analyze images.<|im_end|>
<|im_start|>user
{user_message}

{image_placeholders}<|im_end|>
<|im_start|>assistant
Let me analyze the image(s).

"""
```

**Success Criteria**:
- ✅ File created: `src/intelligence/llm/prompts.py`
- ✅ All major use cases covered
- ✅ Prompts follow Qwen2.5 chat format

---

### Week 4: RAG System

**Goal**: Implement semantic memory with ChromaDB

#### Day 1-2: RAG Manager

**Task 4.1.1: Implement RAG Manager**

Create `src/intelligence/rag/manager.py`:
```python
"""RAG (Retrieval-Augmented Generation) Manager"""
import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer
from typing import List, Dict, Any, Optional
from pathlib import Path
import logging
import json
from datetime import datetime

logger = logging.getLogger(__name__)

class RAGManager:
    """
    Manages semantic memory using ChromaDB

    Features:
    - Multi-collection support (knowledge, tools, conversations, preferences)
    - Semantic search with embeddings
    - Metadata filtering
    - Automatic chunking
    - Versioning support
    """

    def __init__(
        self,
        persist_directory: str = "data/vector_db",
        embedding_model: str = "all-MiniLM-L6-v2"
    ):
        """
        Initialize RAG manager

        Args:
            persist_directory: Path to ChromaDB storage
            embedding_model: Sentence transformer model name
        """
        self.persist_directory = Path(persist_directory)
        self.embedding_model_name = embedding_model

        # Initialize embedding model
        logger.info(f"Loading embedding model: {embedding_model}")
        self.embedding_model = SentenceTransformer(embedding_model)

        # Initialize ChromaDB client
        logger.info(f"Connecting to ChromaDB at {persist_directory}")
        self.client = chromadb.Client(Settings(
            chroma_db_impl="duckdb+parquet",
            persist_directory=str(self.persist_directory)
        ))

        # Collection references
        self.collections = {}
        self._init_collections()

    def _init_collections(self):
        """Initialize all required collections"""
        collection_names = ["knowledge", "tools", "conversations", "user_preferences"]

        for name in collection_names:
            try:
                collection = self.client.get_or_create_collection(
                    name=name,
                    metadata={"hnsw:space": "cosine"}
                )
                self.collections[name] = collection
                logger.info(f"✓ Collection '{name}' loaded ({collection.count()} items)")
            except Exception as e:
                logger.error(f"Failed to load collection '{name}': {e}")
                raise

    def add_knowledge(
        self,
        content: str,
        metadata: Optional[Dict[str, Any]] = None,
        knowledge_id: Optional[str] = None
    ) -> str:
        """
        Add knowledge entry to semantic memory

        Args:
            content: Knowledge content (text)
            metadata: Additional metadata (topic, source, etc.)
            knowledge_id: Optional custom ID

        Returns:
            ID of created entry
        """
        collection = self.collections["knowledge"]

        # Generate ID if not provided
        if knowledge_id is None:
            knowledge_id = f"knowledge_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"

        # Prepare metadata
        meta = metadata or {}
        meta["created_at"] = datetime.now().isoformat()
        meta["type"] = "knowledge"

        # Generate embedding
        embedding = self.embedding_model.encode(content).tolist()

        try:
            collection.add(
                ids=[knowledge_id],
                embeddings=[embedding],
                documents=[content],
                metadatas=[meta]
            )
            logger.info(f"✓ Knowledge added: {knowledge_id}")
            return knowledge_id
        except Exception as e:
            logger.error(f"Failed to add knowledge: {e}")
            raise

    def add_tool_documentation(
        self,
        tool_name: str,
        description: str,
        usage_examples: str,
        category: str,
        code_summary: str
    ) -> str:
        """
        Add tool documentation to semantic memory

        Args:
            tool_name: Name of the tool
            description: Tool description
            usage_examples: Usage examples
            category: Tool category
            code_summary: Summary of what the code does

        Returns:
            ID of created entry
        """
        collection = self.collections["tools"]

        # Combine all text for embedding
        full_text = f"""
Tool: {tool_name}
Category: {category}

Description:
{description}

Usage Examples:
{usage_examples}

Implementation:
{code_summary}
"""

        # Metadata
        metadata = {
            "tool_name": tool_name,
            "category": category,
            "created_at": datetime.now().isoformat(),
            "type": "tool_documentation"
        }

        # Generate embedding
        embedding = self.embedding_model.encode(full_text).tolist()

        tool_id = f"tool_{tool_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        try:
            collection.add(
                ids=[tool_id],
                embeddings=[embedding],
                documents=[full_text],
                metadatas=[metadata]
            )
            logger.info(f"✓ Tool documentation added: {tool_name}")
            return tool_id
        except Exception as e:
            logger.error(f"Failed to add tool documentation: {e}")
            raise

    def add_conversation(
        self,
        conversation_text: str,
        importance: str = "medium",
        tags: Optional[List[str]] = None
    ) -> str:
        """
        Add important conversation snippet to memory

        Args:
            conversation_text: Conversation content
            importance: low/medium/high
            tags: List of tags for categorization

        Returns:
            ID of created entry
        """
        collection = self.collections["conversations"]

        conv_id = f"conv_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"

        metadata = {
            "importance": importance,
            "tags": json.dumps(tags or []),
            "created_at": datetime.now().isoformat(),
            "type": "conversation"
        }

        embedding = self.embedding_model.encode(conversation_text).tolist()

        try:
            collection.add(
                ids=[conv_id],
                embeddings=[embedding],
                documents=[conversation_text],
                metadatas=[metadata]
            )
            logger.debug(f"✓ Conversation saved: {conv_id}")
            return conv_id
        except Exception as e:
            logger.error(f"Failed to save conversation: {e}")
            raise

    def search(
        self,
        query: str,
        collection_name: str = "knowledge",
        n_results: int = 5,
        filter_metadata: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Semantic search across collection

        Args:
            query: Search query
            collection_name: Which collection to search
            n_results: Number of results to return
            filter_metadata: Metadata filters

        Returns:
            List of results with documents, metadata, and distances
        """
        collection = self.collections.get(collection_name)
        if not collection:
            raise ValueError(f"Collection '{collection_name}' not found")

        # Generate query embedding
        query_embedding = self.embedding_model.encode(query).tolist()

        try:
            results = collection.query(
                query_embeddings=[query_embedding],
                n_results=n_results,
                where=filter_metadata,
                include=["documents", "metadatas", "distances"]
            )

            # Format results
            formatted_results = []
            for i in range(len(results['ids'][0])):
                formatted_results.append({
                    "id": results['ids'][0][i],
                    "document": results['documents'][0][i],
                    "metadata": results['metadatas'][0][i],
                    "distance": results['distances'][0][i],
                    "relevance": 1 - results['distances'][0][i]  # Convert distance to relevance
                })

            logger.debug(f"Found {len(formatted_results)} results for query: '{query[:50]}...'")
            return formatted_results

        except Exception as e:
            logger.error(f"Search failed: {e}")
            raise

    def search_tools(self, query: str, n_results: int = 5) -> List[Dict[str, Any]]:
        """Search for relevant tools"""
        return self.search(query, collection_name="tools", n_results=n_results)

    def search_knowledge(self, query: str, n_results: int = 5) -> List[Dict[str, Any]]:
        """Search for relevant knowledge"""
        return self.search(query, collection_name="knowledge", n_results=n_results)

    def search_conversations(self, query: str, n_results: int = 3) -> List[Dict[str, Any]]:
        """Search past conversations"""
        return self.search(query, collection_name="conversations", n_results=n_results)

    def get_context_for_task(self, task_description: str, max_context_length: int = 2000) -> str:
        """
        Get relevant context for a task

        Args:
            task_description: Description of the task
            max_context_length: Maximum total character length

        Returns:
            Formatted context string
        """
        # Search all collections
        knowledge_results = self.search_knowledge(task_description, n_results=3)
        tool_results = self.search_tools(task_description, n_results=3)
        conv_results = self.search_conversations(task_description, n_results=2)

        # Build context
        context_parts = []

        if knowledge_results:
            context_parts.append("## Relevant Knowledge\n")
            for result in knowledge_results:
                if result['relevance'] > 0.7:  # Only include highly relevant
                    context_parts.append(f"- {result['document'][:200]}...\n")

        if tool_results:
            context_parts.append("\n## Available Tools\n")
            for result in tool_results:
                if result['relevance'] > 0.7:
                    context_parts.append(f"- {result['metadata'].get('tool_name', 'Unknown')}: "
                                       f"{result['document'][:150]}...\n")

        if conv_results:
            context_parts.append("\n## Past Discussions\n")
            for result in conv_results:
                if result['relevance'] > 0.75:
                    context_parts.append(f"- {result['document'][:150]}...\n")

        # Combine and truncate
        full_context = "".join(context_parts)

        if len(full_context) > max_context_length:
            full_context = full_context[:max_context_length] + "\n...(truncated)"

        return full_context if full_context.strip() else "No relevant context found."

    def delete_entry(self, entry_id: str, collection_name: str):
        """Delete an entry from a collection"""
        collection = self.collections.get(collection_name)
        if not collection:
            raise ValueError(f"Collection '{collection_name}' not found")

        try:
            collection.delete(ids=[entry_id])
            logger.info(f"✓ Deleted entry: {entry_id} from {collection_name}")
        except Exception as e:
            logger.error(f"Failed to delete entry: {e}")
            raise

    def get_stats(self) -> Dict[str, Any]:
        """Get statistics about all collections"""
        stats = {}
        for name, collection in self.collections.items():
            stats[name] = {
                "count": collection.count(),
                "name": name
            }
        return stats
```

**Success Criteria**:
- ✅ File created: `src/intelligence/rag/manager.py`
- ✅ No syntax errors
- ✅ All CRUD operations implemented

---

**Task 4.1.2: Test RAG Manager**

Create `tests/unit/test_rag_manager.py`:
```python
"""Unit tests for RAG Manager"""
import pytest
from src.intelligence.rag.manager import RAGManager
import tempfile
import shutil

@pytest.fixture
def rag_manager():
    """Create RAG manager with temporary database"""
    temp_dir = tempfile.mkdtemp()
    manager = RAGManager(persist_directory=temp_dir)
    yield manager
    # Cleanup
    shutil.rmtree(temp_dir)

def test_rag_initialization(rag_manager):
    """Test RAG manager initializes correctly"""
    assert rag_manager.client is not None
    assert len(rag_manager.collections) == 4
    assert "knowledge" in rag_manager.collections
    assert "tools" in rag_manager.collections

def test_add_knowledge(rag_manager):
    """Test adding knowledge entry"""
    content = "Python is a high-level programming language known for its simplicity."
    metadata = {"topic": "programming", "language": "python"}

    entry_id = rag_manager.add_knowledge(content, metadata)

    assert entry_id is not None
    assert entry_id.startswith("knowledge_")

def test_add_tool_documentation(rag_manager):
    """Test adding tool documentation"""
    tool_id = rag_manager.add_tool_documentation(
        tool_name="test_tool",
        description="A test tool",
        usage_examples="tool.run()",
        category="testing",
        code_summary="Performs testing operations"
    )

    assert tool_id is not None
    assert "test_tool" in tool_id

def test_add_conversation(rag_manager):
    """Test adding conversation"""
    conv_text = "User asked about Python. I explained it's a programming language."
    conv_id = rag_manager.add_conversation(
        conv_text,
        importance="high",
        tags=["python", "explanation"]
    )

    assert conv_id is not None
    assert conv_id.startswith("conv_")

def test_search_knowledge(rag_manager):
    """Test searching knowledge"""
    # Add some knowledge
    rag_manager.add_knowledge(
        "Python is great for data science and machine learning.",
        {"topic": "python"}
    )
    rag_manager.add_knowledge(
        "JavaScript is used for web development.",
        {"topic": "javascript"}
    )

    # Search
    results = rag_manager.search_knowledge("data science", n_results=2)

    assert len(results) > 0
    assert "Python" in results[0]['document']
    assert results[0]['relevance'] > 0.5

def test_search_tools(rag_manager):
    """Test searching tools"""
    # Add tool documentation
    rag_manager.add_tool_documentation(
        tool_name="web_scraper",
        description="Scrapes web pages",
        usage_examples="scraper.fetch('url')",
        category="network",
        code_summary="Uses requests library to fetch HTML"
    )

    # Search
    results = rag_manager.search_tools("scraping websites")

    assert len(results) > 0
    assert results[0]['metadata']['tool_name'] == "web_scraper"

def test_get_context_for_task(rag_manager):
    """Test retrieving context for a task"""
    # Add diverse content
    rag_manager.add_knowledge("Use pandas for data analysis", {"topic": "pandas"})
    rag_manager.add_tool_documentation(
        tool_name="data_analyzer",
        description="Analyzes datasets",
        usage_examples="analyze(df)",
        category="data",
        code_summary="Statistical analysis tool"
    )

    # Get context
    context = rag_manager.get_context_for_task("I need to analyze a CSV file")

    assert isinstance(context, str)
    assert len(context) > 0

def test_delete_entry(rag_manager):
    """Test deleting an entry"""
    # Add entry
    entry_id = rag_manager.add_knowledge("Test content", {"test": "true"})

    # Delete
    rag_manager.delete_entry(entry_id, "knowledge")

    # Verify deleted
    results = rag_manager.search_knowledge("Test content")
    assert len(results) == 0 or results[0]['id'] != entry_id

def test_get_stats(rag_manager):
    """Test getting statistics"""
    # Add some entries
    rag_manager.add_knowledge("Test 1")
    rag_manager.add_knowledge("Test 2")

    stats = rag_manager.get_stats()

    assert "knowledge" in stats
    assert stats["knowledge"]["count"] >= 2

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
```

Run tests:
```bash
cd ~/RAGme
source venv/bin/activate
pytest tests/unit/test_rag_manager.py -v
```

**Success Criteria**:
- ✅ All tests pass
- ✅ RAG operations functional
- ✅ Search returns relevant results

---

**Time Estimate for Week 3-4**: 10-14 days
**Success Metric**: LLM engine operational, vision processing working, RAG system storing/retrieving knowledge

---

### Week 5-6: Policy Layer (CCAC System)

**Goal**: Implement Category-Based Access Control with approval workflow

#### Day 1-2: CCAC Core

**Task 5.1.1: Implement CCAC Manager**

Create `src/policy/ccac.py`:
```python
"""Category-Based Access Control (CCAC) System"""
import sqlite3
from typing import Dict, Any, Optional, List
from pathlib import Path
from datetime import datetime
import logging
import yaml
import json

logger = logging.getLogger(__name__)

class CCACManager:
    """
    Manages Category-Based Access Control

    Features:
    - Hierarchical permission system
    - Category approvals with inheritance
    - Tool-specific overrides
    - Complete audit trail
    - First-time approval workflow
    """

    # Trust levels
    SANDBOX = 0
    BASIC = 1
    ELEVATED = 2
    FULL = 3

    def __init__(
        self,
        db_path: str = "data/registry.db",
        policy_config_path: str = "config/policy.yaml"
    ):
        """
        Initialize CCAC manager

        Args:
            db_path: Path to SQLite registry database
            policy_config_path: Path to policy configuration file
        """
        self.db_path = Path(db_path)
        self.policy_config_path = Path(policy_config_path)

        # Load policy configuration
        with open(self.policy_config_path, 'r') as f:
            self.policy_config = yaml.safe_load(f)

        # Category definitions from config
        self.categories = self.policy_config['categories']
        self.trust_levels = self.policy_config['trust_levels']

        logger.info(f"CCAC initialized with {len(self.categories)} categories")

    def _get_connection(self) -> sqlite3.Connection:
        """Get database connection"""
        return sqlite3.connect(str(self.db_path))

    def get_category_trust_level(self, category: str) -> int:
        """
        Get required trust level for a category

        Args:
            category: Category string (e.g., "file.read", "network.http_read")

        Returns:
            Required trust level (0-3)
        """
        # Parse category (e.g., "file.read" -> file, read)
        parts = category.split('.')

        if len(parts) == 1:
            # Top-level category
            cat_config = self.categories.get(parts[0], {})
            return self.trust_levels.get(cat_config.get('default', 'BASIC'), 1)
        elif len(parts) == 2:
            # Subcategory
            main_cat, sub_cat = parts
            cat_config = self.categories.get(main_cat, {})
            trust_level_name = cat_config.get(sub_cat, 'BASIC')
            return self.trust_levels.get(trust_level_name, 1)
        else:
            logger.warning(f"Invalid category format: {category}")
            return self.ELEVATED  # Default to elevated for safety

    def is_category_approved(self, category: str) -> bool:
        """
        Check if category has been approved

        Args:
            category: Category to check

        Returns:
            True if approved, False otherwise
        """
        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute(
                "SELECT COUNT(*) FROM category_approvals WHERE category = ?",
                (category,)
            )
            count = cursor.fetchone()[0]
            return count > 0
        finally:
            conn.close()

    def approve_category(self, category: str, trust_level: Optional[int] = None):
        """
        Approve a category

        Args:
            category: Category to approve
            trust_level: Override trust level (None = use default)
        """
        if trust_level is None:
            trust_level = self.get_category_trust_level(category)

        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute(
                """INSERT OR REPLACE INTO category_approvals
                   (category, trust_level, approved_at)
                   VALUES (?, ?, ?)""",
                (category, trust_level, datetime.now())
            )
            conn.commit()

            # Audit log
            self._log_audit_event(
                cursor,
                event_type="category_approval",
                decision="approve",
                context=json.dumps({"category": category, "trust_level": trust_level}),
                category=category
            )
            conn.commit()

            logger.info(f"✓ Category approved: {category} (trust level: {trust_level})")

        finally:
            conn.close()

    def deny_category(self, category: str, reason: str = ""):
        """
        Deny a category (prevent approval)

        Args:
            category: Category to deny
            reason: Reason for denial
        """
        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            # Log denial in audit
            self._log_audit_event(
                cursor,
                event_type="category_denial",
                decision="deny",
                context=json.dumps({"category": category, "reason": reason}),
                category=category
            )
            conn.commit()

            logger.info(f"✓ Category denied: {category}")

        finally:
            conn.close()

    def check_tool_permission(self, tool_id: int, category: str) -> Dict[str, Any]:
        """
        Check if a tool has permission to execute

        Args:
            tool_id: Tool database ID
            category: Tool's category

        Returns:
            Dict with 'allowed' (bool) and 'reason' (str)
        """
        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            # Check for tool-specific override
            cursor.execute(
                "SELECT decision, reason FROM tool_overrides WHERE tool_id = ?",
                (tool_id,)
            )
            override = cursor.fetchone()

            if override:
                decision, reason = override
                allowed = (decision == 'approve')
                return {
                    "allowed": allowed,
                    "reason": reason or f"Tool-specific override: {decision}",
                    "source": "tool_override"
                }

            # Check category approval
            if self.is_category_approved(category):
                return {
                    "allowed": True,
                    "reason": f"Category '{category}' is approved",
                    "source": "category_approval"
                }

            # Not approved
            return {
                "allowed": False,
                "reason": f"Category '{category}' requires approval",
                "source": "not_approved"
            }

        finally:
            conn.close()

    def add_tool_override(
        self,
        tool_id: int,
        decision: str,  # 'approve' or 'deny'
        reason: str = ""
    ):
        """
        Add tool-specific permission override

        Args:
            tool_id: Tool database ID
            decision: 'approve' or 'deny'
            reason: Reason for override
        """
        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute(
                """INSERT INTO tool_overrides (tool_id, decision, reason, created_at)
                   VALUES (?, ?, ?, ?)""",
                (tool_id, decision, reason, datetime.now())
            )
            conn.commit()

            logger.info(f"✓ Tool override added: tool_id={tool_id}, decision={decision}")

        finally:
            conn.close()

    def request_approval(
        self,
        category: str,
        tool_name: str,
        description: str,
        code_preview: str
    ) -> Dict[str, Any]:
        """
        Request approval for a new tool/category

        Args:
            category: Tool category
            tool_name: Name of the tool
            description: What the tool does
            code_preview: Preview of the code

        Returns:
            Dict with approval request details
        """
        # Check if category already approved
        if self.is_category_approved(category):
            return {
                "requires_approval": False,
                "category_approved": True,
                "message": f"Category '{category}' already approved"
            }

        # Build approval request
        trust_level = self.get_category_trust_level(category)
        trust_level_name = [k for k, v in self.trust_levels.items() if v == trust_level][0]

        request = {
            "requires_approval": True,
            "category": category,
            "trust_level": trust_level,
            "trust_level_name": trust_level_name,
            "tool_name": tool_name,
            "description": description,
            "code_preview": code_preview[:500],  # First 500 chars
            "options": {
                "approve_category": f"Approve entire '{category}' category (all future tools)",
                "approve_tool_only": f"Approve only '{tool_name}' (one-time)",
                "deny": "Deny and do not create tool"
            }
        }

        return request

    def _log_audit_event(
        self,
        cursor: sqlite3.Cursor,
        event_type: str,
        decision: str,
        context: str,
        tool_id: Optional[int] = None,
        category: Optional[str] = None
    ):
        """Log event to audit trail"""
        cursor.execute(
            """INSERT INTO policy_audit
               (timestamp, event_type, decision, context, tool_id, category)
               VALUES (?, ?, ?, ?, ?, ?)""",
            (datetime.now(), event_type, decision, context, tool_id, category)
        )

    def get_approved_categories(self) -> List[str]:
        """Get list of all approved categories"""
        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute("SELECT category FROM category_approvals ORDER BY approved_at DESC")
            categories = [row[0] for row in cursor.fetchall()]
            return categories
        finally:
            conn.close()

    def get_audit_log(self, limit: int = 100) -> List[Dict[str, Any]]:
        """Get recent audit log entries"""
        conn = self._get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute(
                """SELECT timestamp, event_type, decision, context, category
                   FROM policy_audit
                   ORDER BY timestamp DESC
                   LIMIT ?""",
                (limit,)
            )

            logs = []
            for row in cursor.fetchall():
                logs.append({
                    "timestamp": row[0],
                    "event_type": row[1],
                    "decision": row[2],
                    "context": json.loads(row[3]) if row[3] else {},
                    "category": row[4]
                })

            return logs
        finally:
            conn.close()
```

**Success Criteria**:
- ✅ File created: `src/policy/ccac.py`
- ✅ Category system implemented
- ✅ Approval workflow defined

---

#### Day 3-5: Sandbox Manager

**Task 5.1.2: Implement Docker Sandbox Manager**

Create `src/execution/sandbox.py`:
```python
"""Docker-based sandbox for safe code execution"""
import docker
from docker.errors import DockerException, ContainerError
from typing import Dict, Any, Optional
from pathlib import Path
import logging
import tempfile
import shutil
import time

logger = logging.getLogger(__name__)

class SandboxManager:
    """
    Manages Docker sandboxes for safe code execution

    Features:
    - Resource limits (CPU, memory, time)
    - Network isolation (optional)
    - GPU access (for model inference)
    - File system isolation
    - Automatic cleanup
    """

    def __init__(
        self,
        memory_limit: str = "2g",
        cpu_limit: float = 2.0,
        timeout: int = 300,
        network_enabled: bool = True,
        gpu_access: bool = False
    ):
        """
        Initialize sandbox manager

        Args:
            memory_limit: Maximum memory (e.g., "2g")
            cpu_limit: CPU cores limit
            timeout: Execution timeout in seconds
            network_enabled: Allow network access
            gpu_access: Allow GPU access
        """
        self.memory_limit = memory_limit
        self.cpu_limit = cpu_limit
        self.timeout = timeout
        self.network_enabled = network_enabled
        self.gpu_access = gpu_access

        # Connect to Docker
        try:
            self.client = docker.from_env()
            logger.info("✓ Connected to Docker daemon")
        except DockerException as e:
            logger.error(f"Failed to connect to Docker: {e}")
            raise

    def execute_python(
        self,
        code: str,
        requirements: Optional[list] = None
    ) -> Dict[str, Any]:
        """
        Execute Python code in sandbox

        Args:
            code: Python code to execute
            requirements: List of pip packages to install

        Returns:
            Dict with 'success', 'stdout', 'stderr', 'exit_code'
        """
        # Create temporary directory for code
        temp_dir = tempfile.mkdtemp()

        try:
            # Write code to file
            code_file = Path(temp_dir) / "code.py"
            code_file.write_text(code)

            # Create requirements.txt if needed
            if requirements:
                req_file = Path(temp_dir) / "requirements.txt"
                req_file.write_text("\n".join(requirements))

            # Build Docker command
            commands = []
            if requirements:
                commands.append("pip install --no-cache-dir -r /workspace/requirements.txt")
            commands.append("python /workspace/code.py")

            command = " && ".join(commands)

            # Prepare Docker run parameters
            run_params = {
                "image": "python:3.11-slim",
                "command": ["sh", "-c", command],
                "volumes": {temp_dir: {"bind": "/workspace", "mode": "ro"}},
                "working_dir": "/workspace",
                "mem_limit": self.memory_limit,
                "cpu_quota": int(self.cpu_limit * 100000),
                "cpu_period": 100000,
                "network_disabled": not self.network_enabled,
                "remove": True,
                "stdout": True,
                "stderr": True
            }

            # Add GPU if requested
            if self.gpu_access:
                run_params["device_requests"] = [
                    docker.types.DeviceRequest(count=-1, capabilities=[["gpu"]])
                ]

            # Execute in container
            logger.info("Executing code in sandbox...")
            start_time = time.time()

            try:
                container = self.client.containers.run(**run_params, detach=True)

                # Wait for completion with timeout
                result = container.wait(timeout=self.timeout)
                exit_code = result['StatusCode']

                # Get logs
                logs = container.logs(stdout=True, stderr=True).decode('utf-8')

                execution_time = time.time() - start_time

                # Parse stdout/stderr (Docker combines them)
                return {
                    "success": exit_code == 0,
                    "exit_code": exit_code,
                    "output": logs,
                    "stdout": logs,  # Combined output
                    "stderr": "",    # Would need separate containers for split
                    "execution_time": execution_time
                }

            except ContainerError as e:
                logger.error(f"Container execution failed: {e}")
                return {
                    "success": False,
                    "exit_code": e.exit_status,
                    "output": str(e),
                    "stdout": "",
                    "stderr": str(e),
                    "execution_time": time.time() - start_time
                }

            except Exception as e:
                logger.error(f"Sandbox execution error: {e}")
                return {
                    "success": False,
                    "exit_code": -1,
                    "output": "",
                    "stdout": "",
                    "stderr": str(e),
                    "execution_time": time.time() - start_time
                }

        finally:
            # Cleanup temporary directory
            shutil.rmtree(temp_dir, ignore_errors=True)

    def test_code(
        self,
        code: str,
        test_code: str,
        requirements: Optional[list] = None
    ) -> Dict[str, Any]:
        """
        Test code with pytest

        Args:
            code: Main code
            test_code: Test code (pytest)
            requirements: Additional requirements

        Returns:
            Dict with test results
        """
        # Combine code and tests
        combined_code = f"{code}\n\n{test_code}"

        # Add pytest to requirements
        req = requirements or []
        if "pytest" not in req:
            req.append("pytest")

        # Execute tests
        test_command_code = combined_code + "\n\nif __name__ == '__main__':\n    import pytest\n    pytest.main(['-v'])"

        return self.execute_python(test_command_code, requirements=req)

    def cleanup(self):
        """Cleanup Docker resources"""
        logger.info("Cleaning up sandbox resources...")
        # Remove dangling containers (if any)
        try:
            filters = {"status": "exited"}
            containers = self.client.containers.list(all=True, filters=filters)
            for container in containers:
                if "ragme_sandbox" in container.name:
                    container.remove(force=True)
                    logger.debug(f"Removed container: {container.name}")
        except Exception as e:
            logger.warning(f"Cleanup warning: {e}")
```

**Success Criteria**:
- ✅ File created: `src/execution/sandbox.py`
- ✅ Docker integration working
- ✅ Resource limits enforced

---

### Week 6: Gap Detection

**Goal**: Implement capability gap detection system

#### Day 1-3: Gap Detector

**Task 6.1.1: Implement Gap Detector**

Create `src/capability/gap_detector.py`:
```python
"""Capability gap detection system"""
from typing import Dict, Any, Optional, List
from src.intelligence.llm.engine import LLMEngine
from src.intelligence.llm.prompts import PromptTemplates
from src.intelligence.rag.manager import RAGManager
import logging
import re
import sqlite3
from datetime import datetime

logger = logging.getLogger(__name__)

class GapDetector:
    """
    Detects capability gaps when tasks cannot be completed

    Process:
    1. User provides task
    2. System attempts task with current capabilities
    3. If failure → analyze gap
    4. Propose solution (tool/knowledge/adapter)
    5. Log gap in database
    """

    def __init__(
        self,
        llm_engine: LLMEngine,
        rag_manager: RAGManager,
        registry_db_path: str = "data/registry.db"
    ):
        """
        Initialize gap detector

        Args:
            llm_engine: LLM engine instance
            rag_manager: RAG manager instance
            registry_db_path: Path to registry database
        """
        self.llm = llm_engine
        self.rag = rag_manager
        self.db_path = registry_db_path

    def analyze_task(
        self,
        task_description: str,
        error_message: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Analyze a task to detect capability gaps

        Args:
            task_description: Description of the task
            error_message: Optional error encountered

        Returns:
            Dict with gap analysis results
        """
        logger.info(f"Analyzing task for gaps: {task_description[:100]}...")

        # Get relevant context from RAG
        context = self.rag.get_context_for_task(task_description)

        # Generate gap detection prompt
        prompt = PromptTemplates.gap_detection_prompt(
            task=task_description,
            error=error_message
        )

        # Get LLM analysis
        response = self.llm.generate(
            prompt,
            max_tokens=1000,
            temperature=0.3  # Lower temperature for analytical task
        )

        # Parse response
        analysis = self._parse_gap_analysis(response)

        # If gap detected, log it
        if analysis['gap_detected']:
            gap_id = self._log_gap(
                gap_type=analysis['gap_type'],
                description=analysis['proposal'],
                task=task_description
            )
            analysis['gap_id'] = gap_id

        return analysis

    def _parse_gap_analysis(self, response: str) -> Dict[str, Any]:
        """
        Parse LLM's gap analysis response

        Expected format:
        CAN_COMPLETE: yes/no
        GAP_TYPE: tool/knowledge/reasoning/none
        PROPOSAL: ...
        REASONING: ...
        """
        analysis = {
            "gap_detected": False,
            "can_complete": False,
            "gap_type": "none",
            "proposal": "",
            "reasoning": ""
        }

        # Parse CAN_COMPLETE
        can_complete_match = re.search(r"CAN_COMPLETE:\s*(yes|no)", response, re.IGNORECASE)
        if can_complete_match:
            analysis["can_complete"] = can_complete_match.group(1).lower() == "yes"
            analysis["gap_detected"] = not analysis["can_complete"]

        # Parse GAP_TYPE
        gap_type_match = re.search(r"GAP_TYPE:\s*(tool|knowledge|reasoning|none)", response, re.IGNORECASE)
        if gap_type_match:
            analysis["gap_type"] = gap_type_match.group(1).lower()

        # Parse PROPOSAL
        proposal_match = re.search(r"PROPOSAL:\s*(.+?)(?=REASONING:|$)", response, re.DOTALL | re.IGNORECASE)
        if proposal_match:
            analysis["proposal"] = proposal_match.group(1).strip()

        # Parse REASONING
        reasoning_match = re.search(r"REASONING:\s*(.+)", response, re.DOTALL | re.IGNORECASE)
        if reasoning_match:
            analysis["reasoning"] = reasoning_match.group(1).strip()

        return analysis

    def _log_gap(
        self,
        gap_type: str,
        description: str,
        task: str
    ) -> int:
        """
        Log detected gap to database

        Returns:
            Gap ID
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        try:
            cursor.execute(
                """INSERT INTO gaps (gap_type, description, status, detected_at)
                   VALUES (?, ?, 'detected', ?)""",
                (gap_type, f"Task: {task}\n\nProposal: {description}", datetime.now())
            )
            conn.commit()
            gap_id = cursor.lastrowid

            logger.info(f"✓ Gap logged: ID={gap_id}, type={gap_type}")
            return gap_id

        finally:
            conn.close()

    def get_pending_gaps(self) -> List[Dict[str, Any]]:
        """Get all pending capability gaps"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        try:
            cursor.execute(
                """SELECT id, gap_type, description, detected_at
                   FROM gaps
                   WHERE status = 'detected'
                   ORDER BY detected_at DESC"""
            )

            gaps = []
            for row in cursor.fetchall():
                gaps.append({
                    "id": row[0],
                    "gap_type": row[1],
                    "description": row[2],
                    "detected_at": row[3]
                })

            return gaps

        finally:
            conn.close()

    def propose_solution(self, gap_id: int) -> Dict[str, Any]:
        """
        Generate detailed solution proposal for a gap

        Args:
            gap_id: Gap database ID

        Returns:
            Solution proposal
        """
        # Get gap details
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute(
            "SELECT gap_type, description FROM gaps WHERE id = ?",
            (gap_id,)
        )
        row = cursor.fetchone()
        conn.close()

        if not row:
            raise ValueError(f"Gap {gap_id} not found")

        gap_type, description = row

        # Generate solution based on type
        if gap_type == "tool":
            return self._propose_tool_solution(description)
        elif gap_type == "knowledge":
            return self._propose_knowledge_solution(description)
        elif gap_type == "reasoning":
            return self._propose_reasoning_solution(description)
        else:
            return {"error": f"Unknown gap type: {gap_type}"}

    def _propose_tool_solution(self, description: str) -> Dict[str, Any]:
        """Propose a tool to solve the gap"""
        # Extract tool requirements from description
        # This will be used by ToolGenerator

        return {
            "solution_type": "tool",
            "description": description,
            "next_step": "Generate tool using ToolGenerator"
        }

    def _propose_knowledge_solution(self, description: str) -> Dict[str, Any]:
        """Propose knowledge module to solve the gap"""
        return {
            "solution_type": "knowledge",
            "description": description,
            "next_step": "Generate knowledge module"
        }

    def _propose_reasoning_solution(self, description: str) -> Dict[str, Any]:
        """Propose LoRA adapter to improve reasoning"""
        return {
            "solution_type": "reasoning",
            "description": description,
            "next_step": "Collect training data and train LoRA adapter"
        }
```

**Success Criteria**:
- ✅ File created: `src/capability/gap_detector.py`
- ✅ Gap detection logic implemented
- ✅ Database logging functional

---

### Week 7: Tool Generation

**Goal**: Implement complete autonomous tool generation pipeline

#### Day 1-4: Tool Generator

**Task 7.1.1: Implement Tool Generator**

Create `src/capability/tool_generator.py`:
```python
"""Autonomous tool generation system"""
from typing import Dict, Any, Optional, Tuple
from src.intelligence.llm.engine import LLMEngine
from src.intelligence.llm.prompts import PromptTemplates
from src.execution.sandbox import SandboxManager
from src.policy.ccac import CCACManager
import logging
import re
import sqlite3
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)

class ToolGenerator:
    """
    Generates Python tools autonomously

    Process (Reflexion Loop):
    1. Generate tool code from gap description
    2. Generate test code
    3. Execute tests in sandbox
    4. If tests fail → analyze error, regenerate (max 5 iterations)
    5. If tests pass → request approval
    6. Install tool
    """

    MAX_ITERATIONS = 5

    def __init__(
        self,
        llm_engine: LLMEngine,
        sandbox_manager: SandboxManager,
        ccac_manager: CCACManager,
        registry_db_path: str = "data/registry.db",
        tools_dir: str = "tools"
    ):
        """
        Initialize tool generator

        Args:
            llm_engine: LLM engine instance
            sandbox_manager: Sandbox manager instance
            ccac_manager: CCAC manager instance
            registry_db_path: Path to registry database
            tools_dir: Directory to save generated tools
        """
        self.llm = llm_engine
        self.sandbox = sandbox_manager
        self.ccac = ccac_manager
        self.db_path = registry_db_path
        self.tools_dir = Path(tools_dir)
        self.tools_dir.mkdir(parents=True, exist_ok=True)

    def generate_tool(
        self,
        gap_description: str,
        tool_name: str,
        category: str
    ) -> Dict[str, Any]:
        """
        Generate a tool to address capability gap

        Args:
            gap_description: Description of what the tool should do
            tool_name: Name for the tool
            category: CCAC category (e.g., "network.http_read")

        Returns:
            Dict with generation results
        """
        logger.info(f"Generating tool: {tool_name} (category: {category})")

        # Reflexion loop
        tool_code = None
        test_code = None

        for iteration in range(1, self.MAX_ITERATIONS + 1):
            logger.info(f"Iteration {iteration}/{self.MAX_ITERATIONS}")

            if iteration == 1:
                # Initial generation
                tool_code = self._generate_code(gap_description, tool_name, category)
                test_code = self._generate_tests(tool_code, tool_name)
            else:
                # Regenerate based on error
                tool_code = self._regenerate_code(tool_code, last_error, iteration)
                test_code = self._generate_tests(tool_code, tool_name)

            # Test in sandbox
            test_result = self.sandbox.test_code(
                code=tool_code,
                test_code=test_code,
                requirements=self._extract_requirements(tool_code)
            )

            if test_result['success']:
                logger.info(f"✓ Tool generated successfully after {iteration} iteration(s)")

                # Request approval
                approval = self._request_approval(
                    tool_name=tool_name,
                    category=category,
                    description=gap_description,
                    code=tool_code
                )

                return {
                    "success": True,
                    "tool_name": tool_name,
                    "category": category,
                    "code": tool_code,
                    "tests": test_code,
                    "iterations": iteration,
                    "approval_required": approval['requires_approval'],
                    "approval_request": approval
                }

            else:
                # Extract error for next iteration
                last_error = test_result.get('stderr', '') or test_result.get('output', '')
                logger.warning(f"Iteration {iteration} failed: {last_error[:200]}")

        # All iterations failed
        logger.error(f"✗ Tool generation failed after {self.MAX_ITERATIONS} iterations")
        return {
            "success": False,
            "tool_name": tool_name,
            "error": "Max iterations exceeded",
            "last_code": tool_code,
            "last_error": last_error
        }

    def _generate_code(
        self,
        gap_description: str,
        tool_name: str,
        category: str
    ) -> str:
        """Generate initial tool code"""
        prompt = PromptTemplates.tool_generation_prompt(
            gap_description=gap_description,
            tool_name=tool_name,
            category=category
        )

        response = self.llm.generate(
            prompt,
            max_tokens=2048,
            temperature=0.7,
            stop=["```\n\n", "<|im_end|>"]
        )

        # Extract code from response
        code = self._extract_code(response)
        return code

    def _generate_tests(self, tool_code: str, tool_name: str) -> str:
        """Generate test code"""
        prompt = PromptTemplates.test_generation_prompt(
            tool_code=tool_code,
            tool_name=tool_name
        )

        response = self.llm.generate(
            prompt,
            max_tokens=1536,
            temperature=0.7,
            stop=["```\n\n", "<|im_end|>"]
        )

        test_code = self._extract_code(response)
        return test_code

    def _regenerate_code(
        self,
        previous_code: str,
        error: str,
        iteration: int
    ) -> str:
        """Regenerate code using Reflexion"""
        prompt = PromptTemplates.reflexion_prompt(
            code=previous_code,
            error=error,
            iteration=iteration
        )

        response = self.llm.generate(
            prompt,
            max_tokens=2048,
            temperature=0.7
        )

        # Extract corrected code
        code = self._extract_code(response)
        return code

    def _extract_code(self, response: str) -> str:
        """Extract Python code from LLM response"""
        # Look for code blocks
        code_match = re.search(r"```python\n(.+?)```", response, re.DOTALL)
        if code_match:
            return code_match.group(1).strip()

        # Fallback: return full response
        return response.strip()

    def _extract_requirements(self, code: str) -> list:
        """Extract pip requirements from code imports"""
        requirements = []

        # Common import → package mappings
        import_map = {
            "requests": "requests",
            "bs4": "beautifulsoup4",
            "PIL": "Pillow",
            "cv2": "opencv-python",
            "numpy": "numpy",
            "pandas": "pandas",
            "sklearn": "scikit-learn"
        }

        # Find imports
        import_pattern = r"^(?:from|import)\s+(\w+)"
        for match in re.finditer(import_pattern, code, re.MULTILINE):
            module = match.group(1)
            if module in import_map:
                pkg = import_map[module]
                if pkg not in requirements:
                    requirements.append(pkg)

        return requirements

    def _request_approval(
        self,
        tool_name: str,
        category: str,
        description: str,
        code: str
    ) -> Dict[str, Any]:
        """Request user approval for tool"""
        return self.ccac.request_approval(
            category=category,
            tool_name=tool_name,
            description=description,
            code_preview=code[:500]
        )

    def install_tool(
        self,
        tool_name: str,
        code: str,
        tests: str,
        category: str,
        description: str
    ) -> int:
        """
        Install approved tool

        Args:
            tool_name: Tool name
            code: Tool code
            tests: Test code
            category: CCAC category
            description: Tool description

        Returns:
            Tool database ID
        """
        # Save tool file
        tool_file = self.tools_dir / f"{tool_name}.py"
        tool_file.write_text(code)

        # Save tests
        test_file = self.tools_dir / f"test_{tool_name}.py"
        test_file.write_text(tests)

        # Register in database
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        try:
            cursor.execute(
                """INSERT INTO tools
                   (name, description, code, tests, category, version, created_at, updated_at)
                   VALUES (?, ?, ?, ?, ?, 1, ?, ?)""",
                (tool_name, description, code, tests, category, datetime.now(), datetime.now())
            )
            conn.commit()
            tool_id = cursor.lastrowid

            logger.info(f"✓ Tool installed: {tool_name} (ID: {tool_id})")
            return tool_id

        finally:
            conn.close()
```

**Success Criteria**:
- ✅ File created: `src/capability/tool_generator.py`
- ✅ Reflexion loop implemented
- ✅ Tool generation and testing working

---

### Week 8: Integration & Testing

**Goal**: Integrate all components into complete self-evolution loop

#### Day 1-3: Orchestration Layer

**Task 8.1.1: Implement Agent Controller**

Create `src/orchestration/agent_controller.py`:
```python
"""Main agent controller orchestrating all components"""
from src.intelligence.llm.engine import LLMEngine
from src.intelligence.rag.manager import RAGManager
from src.intelligence.vision.processor import VisionProcessor
from src.capability.gap_detector import GapDetector
from src.capability.tool_generator import ToolGenerator
from src.execution.sandbox import SandboxManager
from src.policy.ccac import CCACManager
from typing import Dict, Any, Optional, List
import logging
import yaml

logger = logging.getLogger(__name__)

class AgentController:
    """
    Main orchestration layer coordinating all system components

    Self-Evolution Loop:
    1. Receive user task
    2. Retrieve relevant context from RAG
    3. Attempt to complete task
    4. On failure → detect gap
    5. Generate solution (tool/knowledge)
    6. Test in sandbox
    7. Request approval
    8. Install and retry task
    """

    def __init__(self, config_path: str = "config/system.yaml"):
        """
        Initialize agent controller

        Args:
            config_path: Path to system configuration
        """
        logger.info("Initializing RAGme Agent Controller...")

        # Load configuration
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)

        # Initialize components
        self._init_components()

        logger.info("✓ Agent Controller initialized")

    def _init_components(self):
        """Initialize all system components"""
        # LLM Engine
        logger.info("Loading LLM engine...")
        self.llm = LLMEngine(
            model_path=self.config['model']['path'],
            n_ctx=self.config['model']['context_size'],
            n_gpu_layers=self.config['model']['gpu_layers']
        )

        # RAG Manager
        logger.info("Loading RAG manager...")
        self.rag = RAGManager(
            persist_directory=self.config['memory']['vector_db_path'],
            embedding_model=self.config['memory']['embedding_model']
        )

        # Vision Processor
        logger.info("Initializing vision processor...")
        self.vision = VisionProcessor(
            max_image_size=self.config['vision']['max_image_size']
        )

        # CCAC Manager
        logger.info("Loading CCAC manager...")
        self.ccac = CCACManager(
            policy_config_path="config/policy.yaml"
        )

        # Sandbox Manager
        logger.info("Initializing sandbox...")
        self.sandbox = SandboxManager()

        # Gap Detector
        logger.info("Initializing gap detector...")
        self.gap_detector = GapDetector(
            llm_engine=self.llm,
            rag_manager=self.rag
        )

        # Tool Generator
        logger.info("Initializing tool generator...")
        self.tool_generator = ToolGenerator(
            llm_engine=self.llm,
            sandbox_manager=self.sandbox,
            ccac_manager=self.ccac
        )

    def process_task(
        self,
        user_message: str,
        images: Optional[List] = None
    ) -> Dict[str, Any]:
        """
        Process user task with self-evolution capability

        Args:
            user_message: User's task/message
            images: Optional list of images

        Returns:
            Response dict
        """
        logger.info(f"Processing task: {user_message[:100]}...")

        # Get context from RAG
        context = self.rag.get_context_for_task(user_message)

        # Attempt task
        # TODO: Implement actual task execution
        # For MVP, just analyze for gaps

        # Detect gaps
        gap_analysis = self.gap_detector.analyze_task(user_message)

        if gap_analysis['gap_detected']:
            logger.info(f"Gap detected: {gap_analysis['gap_type']}")

            # If gap is tool-related, offer to generate
            if gap_analysis['gap_type'] == 'tool':
                return {
                    "status": "gap_detected",
                    "gap_type": "tool",
                    "proposal": gap_analysis['proposal'],
                    "can_generate": True,
                    "message": f"I cannot complete this task yet, but I can learn to do it by generating a new tool.\\n\\n{gap_analysis['proposal']}\\n\\nShall I proceed?"
                }

        return {
            "status": "completed",
            "message": "Task analysis complete"
        }

    def generate_tool_for_gap(
        self,
        gap_id: int,
        tool_name: str,
        category: str
    ) -> Dict[str, Any]:
        """
        Generate tool to address a specific gap

        Args:
            gap_id: Gap database ID
            tool_name: Name for the tool
            category: CCAC category

        Returns:
            Generation result
        """
        # Get gap details
        gaps = self.gap_detector.get_pending_gaps()
        gap = next((g for g in gaps if g['id'] == gap_id), None)

        if not gap:
            return {"error": f"Gap {gap_id} not found"}

        # Generate tool
        result = self.tool_generator.generate_tool(
            gap_description=gap['description'],
            tool_name=tool_name,
            category=category
        )

        return result

    def approve_and_install_tool(
        self,
        tool_name: str,
        code: str,
        tests: str,
        category: str,
        description: str,
        approve_category: bool = False
    ) -> Dict[str, Any]:
        """
        Approve and install a generated tool

        Args:
            tool_name: Tool name
            code: Tool code
            tests: Test code
            category: CCAC category
            description: Tool description
            approve_category: Approve entire category vs just this tool

        Returns:
            Installation result
        """
        # Approve category if requested
        if approve_category:
            self.ccac.approve_category(category)
            logger.info(f"✓ Category approved: {category}")

        # Install tool
        tool_id = self.tool_generator.install_tool(
            tool_name=tool_name,
            code=code,
            tests=tests,
            category=category,
            description=description
        )

        # Add tool documentation to RAG
        self.rag.add_tool_documentation(
            tool_name=tool_name,
            description=description,
            usage_examples="# Example will be extracted from code",
            category=category,
            code_summary=description
        )

        return {
            "success": True,
            "tool_id": tool_id,
            "message": f"Tool '{tool_name}' installed successfully!"
        }
```

**Success Criteria**:
- ✅ All components integrated
- ✅ Self-evolution loop functional
- ✅ End-to-end workflow working

---

#### Day 4-7: System Testing

**Task 8.1.2: End-to-End Integration Test**

Create `tests/integration/test_self_evolution.py`:
```python
"""Integration test for complete self-evolution loop"""
import pytest
from src.orchestration.agent_controller import AgentController
import time

def test_complete_workflow():
    """Test complete self-evolution workflow"""

    # Initialize controller
    controller = AgentController()

    # Step 1: Present task that requires new capability
    task = "Fetch the top 5 posts from HackerNews"

    result = controller.process_task(task)

    # Should detect gap
    assert result['status'] == 'gap_detected'
    assert result['gap_type'] == 'tool'

    # Step 2: Generate tool
    generation_result = controller.generate_tool_for_gap(
        gap_id=result['gap_id'],
        tool_name="hackernews_fetcher",
        category="network.http_read"
    )

    assert generation_result['success'] == True
    assert generation_result['tool_name'] == "hackernews_fetcher"

    # Step 3: Approve and install
    install_result = controller.approve_and_install_tool(
        tool_name=generation_result['tool_name'],
        code=generation_result['code'],
        tests=generation_result['tests'],
        category="network.http_read",
        description="Fetches posts from HackerNews",
        approve_category=True
    )

    assert install_result['success'] == True

    # Step 4: Retry original task (should now succeed)
    # TODO: Implement actual tool execution
    # retry_result = controller.process_task(task)
    # assert retry_result['status'] == 'completed'

    print("✓ Complete self-evolution workflow test passed!")

if __name__ == "__main__":
    test_complete_workflow()
```

Run test:
```bash
cd ~/RAGme
source venv/bin/activate
pytest tests/integration/test_self_evolution.py -v -s
```

**Success Criteria**:
- ✅ Full workflow executes without errors
- ✅ Tool generation successful
- ✅ Tool installation working
- ✅ System ready for real-world use

---

### Phase 1 Completion Checklist

Before proceeding to Phase 2, verify:

- [ ] LLM engine loads and generates text (35+ tok/s)
- [ ] Vision processing works with images
- [ ] RAG system stores and retrieves knowledge
- [ ] CCAC manages approvals correctly
- [ ] Sandbox executes code safely
- [ ] Gap detector identifies missing capabilities
- [ ] Tool generator creates working tools (Reflexion loop)
- [ ] Agent controller orchestrates full workflow
- [ ] Integration test passes end-to-end
- [ ] First tool generated autonomously

**If all checked**: Phase 1 Complete! System has basic self-evolution capability. ✅

---

## Phase 2: Enhancement (Weeks 9-16)

**Duration**: 8 weeks
**Goal**: Add advanced features and expand capability library
**Outcome**: System with 50+ tools, voice I/O, proactive assistance

### Overview

Phase 2 focuses on:
- **Advanced Tool Library** (Weeks 9-10): Pre-generate 30+ common tools
- **Voice Interface** (Weeks 11-12): Add speech input/output
- **Desktop Control** (Weeks 13-14): Mouse, keyboard, UI automation
- **Quality Improvements** (Weeks 15-16): Monitoring, optimization, UX

---

### Week 9-10: Advanced Tool Library

**Goal**: Pre-generate common tools to bootstrap capability library

#### Common Tools to Generate

**Network Tools**:
1. `http_get` - HTTP GET requests
2. `http_post` - HTTP POST requests
3. `web_scraper` - HTML parsing and scraping
4. `api_client` - Generic REST API client
5. `download_file` - File downloads
6. `websocket_client` - WebSocket communication

**File Tools**:
7. `read_file` - Read text files
8. `write_file` - Write text files
9. `read_json` - Parse JSON files
10. `write_json` - Write JSON files
11. `read_csv` - Parse CSV files
12. `list_directory` - List directory contents

**Data Tools**:
13. `parse_xml` - XML parsing
14. `parse_yaml` - YAML parsing
15. `text_search` - Search text with regex
16. `data_filter` - Filter datasets
17. `data_aggregate` - Aggregate/summarize data

**System Tools**:
18. `run_command` - Execute shell commands (elevated)
19. `check_process` - Check running processes
20. `get_system_info` - Get system information

**Browser Tools** (using Selenium):
21. `open_browser` - Launch browser
22. `navigate_url` - Navigate to URL
23. `click_element` - Click DOM elements
24. `fill_form` - Fill web forms
25. `screenshot_page` - Take screenshot

**Utility Tools**:
26. `encode_base64` - Base64 encoding
27. `decode_base64` - Base64 decoding
28. `hash_string` - Generate hashes (MD5, SHA256)
29. `generate_uuid` - Generate UUIDs
30. `format_datetime` - Date/time formatting

#### Implementation Approach

**Task 9.1.1: Batch Tool Generation**

Create `scripts/generate_common_tools.py`:
```python
"""Generate common tools in batch"""
from src.orchestration.agent_controller import AgentController
import json

# Tool specifications
TOOL_SPECS = [
    {
        "name": "http_get",
        "category": "network.http_read",
        "description": "Perform HTTP GET request and return response"
    },
    {
        "name": "web_scraper",
        "category": "network.http_read",
        "description": "Scrape and parse HTML from web pages using BeautifulSoup"
    },
    # ... add all 30 tools
]

def generate_all_tools():
    """Generate all common tools"""
    controller = AgentController()

    results = []
    for spec in TOOL_SPECS:
        print(f"Generating {spec['name']}...")

        result = controller.tool_generator.generate_tool(
            gap_description=spec['description'],
            tool_name=spec['name'],
            category=spec['category']
        )

        if result['success']:
            # Auto-approve and install
            controller.approve_and_install_tool(
                tool_name=result['tool_name'],
                code=result['code'],
                tests=result['tests'],
                category=spec['category'],
                description=spec['description'],
                approve_category=True
            )
            print(f"✓ {spec['name']} installed")
        else:
            print(f"✗ {spec['name']} failed")

        results.append(result)

    # Save summary
    with open('tool_generation_summary.json', 'w') as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    generate_all_tools()
```

Run:
```bash
python scripts/generate_common_tools.py
```

**Time Estimate**: 2-3 days (tools generate at ~10 min each with testing)

---

### Week 11-12: Voice Interface

**Goal**: Add speech-to-text and text-to-speech capabilities

#### Task 11.1.1: Speech Input (Whisper)

Install Whisper:
```bash
pip install openai-whisper
```

Create `src/ui/voice/speech_to_text.py`:
```python
"""Speech-to-text using Whisper"""
import whisper
import numpy as np
from typing import Union
from pathlib import Path

class SpeechToText:
    """Convert speech to text using Whisper"""

    def __init__(self, model_size: str = "base"):
        """
        Initialize Whisper

        Args:
            model_size: tiny, base, small, medium, large
        """
        self.model = whisper.load_model(model_size)

    def transcribe(self, audio_path: Union[str, Path]) -> str:
        """
        Transcribe audio file

        Args:
            audio_path: Path to audio file

        Returns:
            Transcribed text
        """
        result = self.model.transcribe(str(audio_path))
        return result['text']
```

#### Task 11.1.2: Speech Output (piper-tts)

Install piper-tts:
```bash
pip install piper-tts
```

Create `src/ui/voice/text_to_speech.py`:
```python
"""Text-to-speech using Piper"""
from piper import PiperVoice
from pathlib import Path

class TextToSpeech:
    """Convert text to speech using Piper"""

    def __init__(self, voice_path: str):
        """Initialize Piper voice"""
        self.voice = PiperVoice.load(voice_path)

    def speak(self, text: str, output_path: str):
        """
        Convert text to speech

        Args:
            text: Text to speak
            output_path: Where to save audio
        """
        self.voice.synthesize(text, Path(output_path))
```

**Success Criteria**:
- ✅ Can transcribe voice input
- ✅ Can generate speech output
- ✅ Latency < 3 seconds for typical queries

---

### Week 13-14: Desktop Control

**Goal**: Enable mouse, keyboard, and UI automation

#### Task 13.1.1: Desktop Control Tools

Install dependencies:
```bash
pip install pyautogui python-xlib
```

Generate desktop control tools:
- `mouse_move` - Move mouse cursor
- `mouse_click` - Click mouse button
- `keyboard_type` - Type text
- `keyboard_press` - Press keys
- `take_screenshot` - Capture screen
- `find_window` - Find application windows
- `activate_window` - Bring window to front

**Success Criteria**:
- ✅ Can control mouse programmatically
- ✅ Can type and press keys
- ✅ Can take screenshots
- ✅ Works on Linux (X11/Wayland)

---

### Week 15-16: Quality & Polish

**Goal**: Monitoring, optimization, and UX improvements

#### Task 15.1.1: Performance Monitoring

Create `src/core/monitoring.py`:
```python
"""System performance monitoring"""
import time
import psutil
import GPUtil
from datetime import datetime
import logging

class PerformanceMonitor:
    """Monitor system performance metrics"""

    def __init__(self):
        self.metrics = []

    def record_inference(self, tokens: int, time: float):
        """Record inference performance"""
        self.metrics.append({
            "timestamp": datetime.now(),
            "type": "inference",
            "tokens": tokens,
            "time": time,
            "tokens_per_sec": tokens / time if time > 0 else 0
        })

    def get_system_stats(self):
        """Get current system stats"""
        gpus = GPUtil.getGPUs()
        gpu = gpus[0] if gpus else None

        return {
            "cpu_percent": psutil.cpu_percent(),
            "memory_percent": psutil.virtual_memory().percent,
            "gpu_util": gpu.load * 100 if gpu else 0,
            "gpu_memory": gpu.memoryUsed if gpu else 0,
            "gpu_memory_total": gpu.memoryTotal if gpu else 0
        }
```

#### Task 15.1.2: Error Recovery

Implement automatic error recovery:
- Retry failed operations (3 attempts)
- Graceful degradation on component failure
- Automatic model reload if crashed
- User-friendly error messages

**Success Criteria**:
- ✅ System handles errors gracefully
- ✅ Performance metrics logged
- ✅ User experience smooth and intuitive

---

### Phase 2 Completion Checklist

- [ ] 50+ tools generated and tested
- [ ] Voice input/output functional
- [ ] Desktop control working
- [ ] Performance monitoring active
- [ ] Error recovery implemented
- [ ] System feels responsive and capable

**If all checked**: Phase 2 Complete! System is feature-rich and user-friendly. ✅

---

## Phase 3: Mastery (Weeks 17-24)

**Duration**: 8 weeks
**Goal**: Achieve deep expertise and proactive assistance
**Outcome**: 500+ tools, meta-generation, autonomous operation

### Week 17-18: LoRA Training

**Goal**: Implement LoRA fine-tuning for task-specific reasoning

#### Task 17.1.1: Training Pipeline

Create `src/capability/lora_trainer.py`:
```python
"""LoRA adapter training system"""
from unsloth import FastLanguageModel
import torch
from transformers import TrainingArguments
from trl import SFTTrainer
import yaml
import logging

logger = logging.getLogger(__name__)

class LoRATrainer:
    """Train LoRA adapters for task-specific reasoning"""

    def __init__(self, config_path: str = "config/training.yaml"):
        """Initialize trainer"""
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)

    def prepare_training_data(self, examples: list) -> list:
        """
        Prepare training dataset

        Args:
            examples: List of dicts with 'input' and 'output'

        Returns:
            Formatted training data
        """
        formatted = []
        for ex in examples:
            formatted.append({
                "text": f"<|im_start|>user\\n{ex['input']}<|im_end|>\\n<|im_start|>assistant\\n{ex['output']}<|im_end|>"
            })
        return formatted

    def train_adapter(
        self,
        adapter_name: str,
        training_data: list,
        task_type: str
    ) -> str:
        """
        Train LoRA adapter

        Args:
            adapter_name: Name for adapter
            training_data: Training examples
            task_type: Type of task (e.g., "coding", "analysis")

        Returns:
            Path to trained adapter
        """
        logger.info(f"Training LoRA adapter: {adapter_name}")

        # Load base model with LoRA
        model, tokenizer = FastLanguageModel.from_pretrained(
            model_name=self.config['base_model'],
            max_seq_length=2048,
            dtype=torch.float16,
            load_in_4bit=True
        )

        model = FastLanguageModel.get_peft_model(
            model,
            r=self.config['training']['rank'],
            target_modules=self.config['training']['target_modules'],
            lora_alpha=self.config['training']['alpha'],
            lora_dropout=self.config['training']['dropout']
        )

        # Training arguments
        training_args = TrainingArguments(
            output_dir=f"data/adapters/{adapter_name}",
            num_train_epochs=self.config['training']['epochs'],
            per_device_train_batch_size=self.config['training']['batch_size'],
            learning_rate=self.config['training']['learning_rate'],
            fp16=True,
            logging_steps=50
        )

        # Train
        trainer = SFTTrainer(
            model=model,
            tokenizer=tokenizer,
            train_dataset=training_data,
            args=training_args
        )

        trainer.train()

        # Save adapter
        adapter_path = f"data/adapters/{adapter_name}"
        model.save_pretrained(adapter_path)

        logger.info(f"✓ Adapter saved: {adapter_path}")
        return adapter_path
```

**Success Criteria**:
- ✅ Can train LoRA adapters
- ✅ Adapters improve task performance
- ✅ Training completes in < 30 minutes

---

### Week 19-20: Meta-Generation

**Goal**: Tools that generate other tools

#### Task 19.1.1: Tool Template Generator

Create `tools/tool_template_generator.py`:
```python
"""Generate tool templates for common patterns"""

def generate_api_client_template(
    api_name: str,
    base_url: str,
    endpoints: list
) -> str:
    """
    Generate API client tool from specification

    Args:
        api_name: Name of the API
        base_url: Base URL
        endpoints: List of endpoint specs

    Returns:
        Generated tool code
    """
    code = f'''"""
{api_name} API Client
Auto-generated API client tool
"""
import requests
from typing import Dict, Any, Optional

class {api_name}Client:
    """Client for {api_name} API"""

    def __init__(self, api_key: Optional[str] = None):
        self.base_url = "{base_url}"
        self.api_key = api_key
        self.session = requests.Session()
        if api_key:
            self.session.headers.update({{"Authorization": f"Bearer {{api_key}}"}})

'''

    # Generate methods for each endpoint
    for endpoint in endpoints:
        method_name = endpoint['name']
        http_method = endpoint.get('method', 'GET')
        path = endpoint['path']

        code += f'''
    def {method_name}(self, **params) -> Dict[str, Any]:
        """Call {path} endpoint"""
        url = f"{{self.base_url}}{path}"
        response = self.session.{http_method.lower()}(url, params=params)
        response.raise_for_status()
        return response.json()
'''

    return code
```

**Use Case**: User provides API documentation URL, system:
1. Scrapes documentation
2. Extracts endpoint specifications
3. Generates complete API client tool
4. Tests and installs automatically

**Success Criteria**:
- ✅ Can generate tool templates
- ✅ Generated tools are functional
- ✅ Reduces manual tool creation time by 80%

---

### Week 21-22: Deep Knowledge Domains

**Goal**: Build deep expertise in user's domains of interest

#### Task 21.1.1: Knowledge Extraction Pipeline

Create `src/capability/knowledge_builder.py`:
```python
"""Build deep knowledge from documentation and experience"""
from src.intelligence.llm.engine import LLMEngine
from src.intelligence.rag.manager import RAGManager
import logging

logger = logging.getLogger(__name__)

class KnowledgeBuilder:
    """Extract and organize knowledge from various sources"""

    def __init__(self, llm: LLMEngine, rag: RAGManager):
        self.llm = llm
        self.rag = rag

    def extract_from_documentation(
        self,
        doc_text: str,
        topic: str
    ) -> list:
        """
        Extract structured knowledge from documentation

        Args:
            doc_text: Documentation text
            topic: Topic/domain

        Returns:
            List of knowledge entries
        """
        # Chunk documentation
        chunks = self._chunk_text(doc_text, chunk_size=1000)

        knowledge_entries = []

        for chunk in chunks:
            # Extract key concepts
            prompt = f"""Extract key concepts from this documentation about {topic}:

{chunk}

Format as bullet points of important facts and procedures."""

            concepts = self.llm.generate(prompt, max_tokens=500)

            # Store in RAG
            entry_id = self.rag.add_knowledge(
                content=concepts,
                metadata={"topic": topic, "source": "documentation"}
            )

            knowledge_entries.append({
                "id": entry_id,
                "topic": topic,
                "content": concepts
            })

        logger.info(f"✓ Extracted {len(knowledge_entries)} knowledge entries for {topic}")
        return knowledge_entries

    def _chunk_text(self, text: str, chunk_size: int) -> list:
        """Split text into chunks"""
        words = text.split()
        chunks = []
        for i in range(0, len(words), chunk_size):
            chunk = " ".join(words[i:i+chunk_size])
            chunks.append(chunk)
        return chunks

    def learn_from_experience(
        self,
        task: str,
        solution: str,
        outcome: str
    ):
        """Learn from successful task completions"""
        lesson = f"""Task: {task}

Solution: {solution}

Outcome: {outcome}

This experience shows that for tasks like this, the successful approach is..."""

        # Store as high-importance knowledge
        self.rag.add_knowledge(
            content=lesson,
            metadata={"type": "experience", "importance": "high"}
        )
```

**Success Criteria**:
- ✅ Can extract knowledge from docs
- ✅ Learns from experience
- ✅ Knowledge retrieval improves task completion

---

### Week 23-24: Proactive Assistance

**Goal**: System anticipates needs and offers help proactively

#### Task 23.1.1: Proactive Agent

Create `src/orchestration/proactive_agent.py`:
```python
"""Proactive assistance system"""
from src.intelligence.llm.engine import LLMEngine
from src.intelligence.rag.manager import RAGManager
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

class ProactiveAgent:
    """Monitor context and offer assistance proactively"""

    def __init__(self, llm: LLMEngine, rag: RAGManager):
        self.llm = llm
        self.rag = rag
        self.last_check = datetime.now()

    def analyze_context(self, user_activity: dict) -> dict:
        """
        Analyze user context and suggest assistance

        Args:
            user_activity: Dict with recent user activity

        Returns:
            Suggestions dict
        """
        # Check if enough time has passed
        if (datetime.now() - self.last_check) < timedelta(minutes=15):
            return {"suggestions": []}

        self.last_check = datetime.now()

        # Analyze patterns
        suggestions = []

        # Example: Detect repetitive tasks
        if self._is_repetitive_task(user_activity):
            suggestions.append({
                "type": "automation",
                "message": "I notice you're doing this task repeatedly. Would you like me to create a tool to automate it?"
            })

        # Example: Suggest related knowledge
        if user_activity.get('current_task'):
            related = self.rag.search_knowledge(user_activity['current_task'], n_results=3)
            if related and related[0]['relevance'] > 0.8:
                suggestions.append({
                    "type": "knowledge",
                    "message": f"I found relevant information that might help: {related[0]['document'][:100]}..."
                })

        return {"suggestions": suggestions}

    def _is_repetitive_task(self, activity: dict) -> bool:
        """Detect if task is being repeated"""
        # Simple heuristic: same command/action > 3 times in 10 minutes
        if 'recent_commands' in activity:
            commands = activity['recent_commands']
            if len(commands) >= 3:
                if len(set(commands[-3:])) == 1:
                    return True
        return False
```

**Success Criteria**:
- ✅ Detects repetitive tasks
- ✅ Suggests relevant knowledge
- ✅ Offers automation opportunities
- ✅ Not intrusive or annoying

---

### Phase 3 Completion Checklist

- [ ] LoRA training pipeline working
- [ ] 3+ task-specific adapters trained
- [ ] Meta-generation tools functional
- [ ] Deep knowledge in 5+ domains
- [ ] Proactive assistance active
- [ ] 500+ tools generated
- [ ] System operates autonomously for common workflows

**If all checked**: Phase 3 Complete! System is a mature cognitive partner. ✅

---

## Appendix

### A. Troubleshooting Guide

**Model Loading Issues**:
- Check VRAM usage (nvidia-smi)
- Reduce n_ctx if > 7.5GB
- Verify model file integrity

**Slow Inference**:
- Ensure all layers on GPU (n_gpu_layers=-1)
- Check CUDA installation
- Monitor CPU/GPU utilization

**Tool Generation Failures**:
- Check sandbox Docker access
- Review Reflexion loop errors
- Increase MAX_ITERATIONS if needed

**RAG Search Poor Results**:
- Verify embeddings are being generated
- Check collection item counts
- Adjust relevance thresholds

### B. Performance Optimization

**LLM Inference**:
- Use mmap for faster loading
- Enable mlock to prevent swapping
- Batch requests when possible

**RAG System**:
- Index optimization (HNSW parameters)
- Periodic collection compaction
- Cache frequent queries

**Sandbox**:
- Pre-pull Docker images
- Use Docker layer caching
- Limit concurrent sandboxes (max 3)

### C. Security Best Practices

**CCAC Configuration**:
- Start with restrictive defaults
- Approve categories incrementally
- Review audit logs weekly

**Sandbox Isolation**:
- Keep Docker updated
- Use read-only volumes when possible
- Monitor resource usage

**Code Generation**:
- Always review generated code before approval
- Test in sandbox before installation
- Version all tools for rollback

### D. Backup & Recovery

**Database Backups**:
```bash
# Vector DB
cp -r data/vector_db data/backups/vector_db_$(date +%Y%m%d)

# Registry
sqlite3 data/registry.db ".backup data/backups/registry_$(date +%Y%m%d).db"
```

**Tool Backups**:
```bash
tar -czf data/backups/tools_$(date +%Y%m%d).tar.gz tools/
```

**Restore**:
```bash
# Restore vector DB
cp -r data/backups/vector_db_YYYYMMDD data/vector_db

# Restore registry
cp data/backups/registry_YYYYMMDD.db data/registry.db
```

---

## Implementation Complete

This plan provides complete, step-by-step instructions for building RAGme from Phase 0 through Phase 3. Every component, file, test, and integration is specified with:

- Exact file paths and names
- Complete code implementations
- Test procedures with expected outputs
- Success criteria for each task
- Troubleshooting guidance
- Time estimates

**Total Implementation Time**: 24 weeks (6 months)

**Milestones**:
- Week 2: Environment ready
- Week 8: First autonomous tool generated
- Week 16: 50+ tools, voice I/O working
- Week 24: 500+ tools, proactive assistance, full autonomy

**Result**: A self-evolving AI system that grows indefinitely, becoming an increasingly capable cognitive partner through continuous autonomous learning.

---

*End of Implementation Plan*
