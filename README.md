# RAGME - Self-Evolving AI System

**R**etrieval-**A**ugmented **G**eneration with **M**odular **E**xtensions

A self-evolving AI system that autonomously expands its capabilities through tool generation, knowledge creation, and self-supervised fine-tuning—all running on-premise with complete user control.

---

## 🎯 What is RAGME?

RAGME is an AI system that **teaches itself new capabilities** by:

1. **Detecting what it can't do** (capability gaps)
2. **Creating the solution autonomously** (code/knowledge/training)
3. **Testing it safely** (isolated sandbox)
4. **Asking your permission** (human-in-the-loop)
5. **Installing it permanently** (forever available)
6. **Growing infinitely** (repeat forever)

### The Innovation

Unlike traditional AI systems with fixed capabilities, RAGME grows through three mechanisms:
- **Tools** (Python code modules) → new capabilities
- **Knowledge** (RAG database entries) → new information
- **Adapters** (LoRA fine-tune weights) → improved reasoning

The base model never changes—all improvements are additive, versioned, and reversible.

---

## ✨ Key Features

### Self-Teaching
- Learns from your instructions and data
- Creates its own knowledge modules
- Stores everything in RAG database
- Supports global and context-specific learning

### Autonomous Tool Generation
Creates:
- Browser automation (Playwright/Selenium)
- Desktop control (mouse, keyboard, screenshots)
- API clients and wrappers
- File processors and data parsers
- System utilities
- MCP-compatible tools

**Process**: Code → Tests → Sandbox → Fix (5 iterations) → Approval → Install

### Autonomous Knowledge Generation
- Domain knowledge packs
- Rulebooks and guides
- Workflow patterns
- Skill modules
- User preferences

### Autonomous LoRA Training
- Detects reasoning weaknesses
- Generates synthetic training dataset
- Trains adapter in GPU sandbox
- Validates results
- Loads permanently

### Real-Time Updates
- Installs capabilities during conversation
- Explains what it's doing and why
- Resumes tasks with new abilities

### Safety & Control
- All code tested in isolated Docker containers
- User approval required before installation
- Category-based permission system (approve once, use forever)
- Complete audit trail
- Versioning and rollback for everything

---

## 🏗️ Architecture

```
Self-Evolving Loop:
Task → Gap Detected → Solution Generated
  → Tested → Approved → Installed → Resumed
```

### Components

1. **Intelligence Layer**: Qwen2.5-VL-7B (vision + coding LLM)
2. **Policy Layer**: Hierarchical category-based access control
3. **Capability Layer**: Tool/knowledge/LoRA generators
4. **Execution Layer**: Docker sandboxes + native executor
5. **Persistence Layer**: Vector DB (ChromaDB) + Registry (SQLite)

### Technology Stack

| Component | Technology |
|-----------|------------|
| Base Model | Qwen2.5-VL-7B-Instruct-abliterated |
| Format | GGUF Q4_K_M (~5GB) |
| Inference | llama.cpp (40+ tok/s) |
| Training | Unsloth + QLoRA |
| Vector DB | ChromaDB |
| Sandbox | Docker |
| Language | Python 3.11+ |

---

## 📋 Requirements

### Hardware
- **CPU**: Intel i9-13th Gen (or equivalent)
- **GPU**: NVIDIA RTX 4060 8GB VRAM
- **RAM**: 32GB recommended
- **Storage**: 100GB SSD

### Software
- Kali Linux (or Ubuntu/Debian)
- Python 3.11+
- Docker 24+
- CUDA 12.1+
- NVIDIA drivers

---

## 🚀 Quick Start

### Option A: Automated Installation (Recommended)

**One-command setup for Kali Linux with RTX 4060:**

```bash
git clone <repository-url> RAGme
cd RAGme
./setup_phase0.sh
```

This script automatically:
- ✓ Checks prerequisites
- ✓ Installs Docker + NVIDIA Container Toolkit
- ✓ Downloads Qwen2.5-VL-7B model (~5GB)
- ✓ Sets up Python environment with CUDA
- ✓ Initializes databases
- ✓ Creates configuration files
- ✓ Verifies everything works

**Time**: 1-3 hours (mostly download time)

See **`QUICKSTART.md`** for details.

### Option B: Manual Installation

See **`INSTALL.md`** for detailed step-by-step instructions.

### Verify Installation

After setup, verify everything works:

```bash
source venv/bin/activate
python3 verify_installation.py
```

This checks:
- Python dependencies
- GPU access
- Model file
- Databases
- Docker
- Optional: Test model loading

---

## 📖 Documentation

### Installation Guides

- **`QUICKSTART.md`** - One-command automated setup (start here!)
- **`INSTALL.md`** - Detailed manual installation guide
- **`setup_phase0.sh`** - Automated installation script
- **`verify_installation.py`** - Installation verification tool

### System Documentation

Complete documentation in `doc/`:

- **`00_executive_summary.md`** - Quick overview
- **`01_system_understanding.md`** - Detailed vision and specs
- **`02_requirements.md`** - All 134 requirements
- **`03_system_design.md`** - Complete architecture
- **`04_implementation_plan.md`** - 20-week development roadmap

---

## 🛠️ Development Status

### Current Phase: Phase 0 - Foundation Setup ✅

**Completed**:
- ✅ Git repository initialized
- ✅ Project structure created
- ✅ Requirements defined
- ✅ Configuration templates created
- ✅ Database schema designed
- ✅ Installation guide written

**Next**: Complete Phase 0 on actual Kali Linux machine with RTX 4060

### Roadmap

| Phase | Duration | Status |
|-------|----------|--------|
| 0. Foundation | Week 1-2 | 🏗️ In Progress |
| 1. Intelligence | Week 3-5 | ⏳ Pending |
| 2. Policy | Week 6-7 | ⏳ Pending |
| 3. Sandbox | Week 8-9 | ⏳ Pending |
| 4. Generation | Week 10-12 | ⏳ Pending |
| 5. Orchestration | Week 13-14 | ⏳ Pending |
| 6. UI | Week 15-16 | ⏳ Pending |
| 7. Integration | Week 17-18 | ⏳ Pending |
| 8. Documentation | Week 19-20 | ⏳ Pending |

**Total Timeline**: 20 weeks (5 months)

---

## 🎯 Expected Growth

| Timeframe | Tools | Knowledge | Adapters |
|-----------|-------|-----------|----------|
| Week 1 | 1 | 10 | 0 |
| Month 1 | 20 | 50 | 2 |
| Month 3 | 100 | 200 | 5 |
| Month 6 | 500+ | 1000+ | 15 |

---

## 🔒 Security

Multi-layer security architecture:

1. **User-Controlled Policy** - Hierarchical category-based permissions
2. **Approval System** - First-time approval per category
3. **Sandbox Isolation** - All code in Docker containers
4. **Audit Logging** - Complete transparency
5. **Versioning** - Instant rollback capability

---

## 📊 Project Structure

```
RAGme/
├── doc/              # Complete documentation
├── src/              # Source code
│   ├── core/         # Core utilities
│   ├── intelligence/ # LLM engine, RAG, vision
│   ├── policy/       # CCAC policy system
│   ├── capability/   # Generators (tool/knowledge/LoRA)
│   ├── execution/    # Sandboxes and executors
│   ├── orchestration/# Agent controller
│   ├── persistence/  # Databases
│   └── ui/           # CLI, API, MCP
├── config/           # Configuration files
├── data/             # Models, databases
├── tests/            # Test suite
├── tools/            # Generated tools
├── knowledge/        # Knowledge modules
└── sandbox/          # Sandbox configurations
```

---

## 🧪 Testing

```bash
# Run all tests
pytest

# Run specific test types
pytest tests/unit/
pytest tests/integration/
pytest tests/system/

# With coverage
pytest --cov=src --cov-report=html
```

---

## 🤝 Contributing

This is currently a single-user system in active development.

Follow the implementation plan in `doc/04_implementation_plan.md`.

---

## 📄 License

[To be determined]

---

## 🙏 Acknowledgments

Built on:
- Qwen2.5-VL by Alibaba Cloud
- llama.cpp by ggerganov
- Unsloth by unslothai
- ChromaDB by Chroma
- And many other open-source projects

---

## 📬 Contact

[To be added]

---

## 🎓 Learn More

- Read `doc/00_executive_summary.md` for a 15-minute overview
- Read `doc/01_system_understanding.md` for deep dive
- Follow `INSTALL.md` for setup
- See `doc/04_implementation_plan.md` for development roadmap

---

**Status**: Phase 0 in progress - Foundation setup

**Next Milestone**: Environment Ready (Phase 0 complete)

---

*RAGME: The AI that grows with you, forever.*
