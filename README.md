# RAGme - Self-Evolving AI System

**Autonomous Cognitive Partner for Personal Use**

A practical self-evolving AI system that autonomously expands its capabilities through tool generation, knowledge creation, and adaptive learning—designed for single-user deployment on 8GB VRAM hardware.

---

## 🎯 What is RAGme?

RAGme is an AI system that **teaches itself new capabilities** autonomously:

1. **Detects capability gaps** when it encounters tasks it cannot complete
2. **Generates solutions** (tools, knowledge modules, or reasoning adapters)
3. **Tests safely** in isolated sandbox environments
4. **Requests approval** from you before installation
5. **Installs permanently** - capability available forever
6. **Grows infinitely** - repeats this cycle endlessly

### The Core Innovation

Unlike traditional AI systems with fixed capabilities, RAGme **evolves through use**:

- **Tools** (Python modules) → New capabilities (web scraping, API clients, automation)
- **Knowledge** (RAG entries) → Domain expertise (guides, workflows, best practices)
- **Adapters** (LoRA weights) → Improved reasoning (task-specific fine-tuning)

The base model remains unchanged—all improvements are modular, versioned, and reversible.

---

## ✨ Key Features

### Autonomous Capability Growth
- Continuously monitors for missing abilities
- Generates solutions without human intervention
- Self-corrects through iterative testing (Reflexion loop)
- Requests approval before making changes
- Versions everything for instant rollback

### Self-Teaching
- Learns from your natural language instructions
- Creates knowledge modules from explanations
- Stores everything in semantic memory (RAG)
- Supports both global and contextual learning

### Vision & Desktop Control
- Sees your screen through vision processing
- Controls mouse, keyboard, applications
- Understands UI elements and workflows
- Automates complex desktop tasks

### Safety & Transparency
- Category-based access control (approve once, use forever)
- All code tested in Docker sandboxes
- Complete audit trail of all actions
- Full reasoning transparency (chain-of-thought)
- User maintains complete control

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   USER INTERFACE                         │
│  CLI + Optional Voice Input (Phase 2)                   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                  ORCHESTRATION LAYER                     │
│  Agent Controller | Self-Evolution Loop                 │
│  Gap Detection → Solution → Test → Approve → Install    │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                 INTELLIGENCE LAYER                       │
│  Qwen2.5-VL-7B (Vision + Reasoning + Coding)           │
│  + Hot-Swappable LoRA Adapters                          │
│  Total: ~7GB VRAM (fits 8GB hardware)                   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                 CAPABILITY LAYER                         │
│  Tool Generator | Knowledge Generator | LoRA Trainer    │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                POLICY & SAFETY LAYER                     │
│  CCAC System | Sandbox Manager | Audit Logger           │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                 PERSISTENCE LAYER                        │
│  ChromaDB (Vector + Metadata) | SQLite (Registry)       │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Requirements

### Hardware
- **CPU**: Intel i9-13th Gen or equivalent (multi-core recommended)
- **GPU**: NVIDIA RTX 4060 8GB VRAM (or similar 8GB GPU)
- **RAM**: 32GB recommended (16GB minimum)
- **Storage**: 100GB SSD (NVMe preferred)

### Software
- **OS**: Kali Linux, Ubuntu 22.04+, or Debian 12+
- **Python**: 3.11 or later
- **Docker**: 24.0+ with nvidia-container-toolkit
- **CUDA**: 12.1+ with compatible NVIDIA drivers

### Performance Targets
- **Inference**: ≥35 tokens/second
- **VRAM Usage**: ≤7.5GB during inference
- **Context Window**: 4096 tokens
- **Model Load Time**: ≤15 seconds

---

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone <repository-url> RAGme
cd RAGme
```

### 2. Install Dependencies
```bash
# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install Python packages
pip install -r requirements.txt

# Install llama.cpp with CUDA support
cd ~/projects
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make LLAMA_CUDA=1 -j$(nproc)

# Install Python bindings
CMAKE_ARGS="-DLLAMA_CUDA=1" pip install llama-cpp-python
```

### 3. Download Model
```bash
# Download Qwen2.5-VL-7B GGUF (Q4_K_M quantization)
./download_model.sh

# Or manually:
pip install huggingface-hub
huggingface-cli download Qwen/Qwen2.5-VL-7B-Instruct-GGUF \
  qwen2.5-vl-7b-instruct-q4_k_m.gguf \
  --local-dir data/models
```

### 4. Initialize Databases
```bash
# Setup ChromaDB and SQLite
python -m src.persistence.init_db

# Verify installation
python verify_installation.py
```

### 5. Run System
```bash
# Start CLI interface
python -m src.ui.cli.main
```

---

## 📖 Documentation

### Core Documents

| Document | Description | Read Time |
|----------|-------------|-----------|
| **[01_DESIGN.md](docs/01_DESIGN.md)** | Complete system design and architecture specification | 45 min |
| **[02_ARCHITECTURE.md](docs/02_ARCHITECTURE.md)** | Detailed component breakdown and data flows | 30 min |
| **[03_IMPLEMENTATION.md](docs/03_IMPLEMENTATION.md)** | Phase-by-phase implementation guide with code examples | 60 min |

### Quick Reference

- **[QUICKSTART.md](QUICKSTART.md)** - Automated setup guide
- **[config/](config/)** - Configuration templates
- **[tests/](tests/)** - Test suite and examples

---

## 🛠️ Development Status

### Current Phase: Phase 1 - Core System (Weeks 3-8)

```
Phase 0: Foundation ✅ COMPLETED
├── Repository structure
├── Documentation
├── System design
└── Installation automation

Phase 1: Core System 🎯 IN PROGRESS
├── Week 3-4: LLM Engine          [⏳ Next]
├── Week 4-5: RAG System          [📋 Planned]
├── Week 5-6: Policy Layer        [📋 Planned]
├── Week 6:   Gap Detection       [📋 Planned]
├── Week 7:   Tool Generation     [📋 Planned]
└── Week 8:   Integration         [📋 Planned]

Phase 2: Enhancement (Weeks 9-16)  [🔮 Future]
└── Advanced tools, voice I/O, quality improvements

Phase 3: Mastery (Weeks 17-24)     [🔮 Future]
└── Meta-generation, deep expertise, proactive assistance
```

**Timeline**: 8 weeks to working MVP
**Success Metric**: Generate first tool autonomously end-to-end

---

## 🎓 How It Works

### Example: Learning to Scrape HackerNews

```
You: "Download the top 10 HackerNews posts and summarize them"

System: "I cannot access HackerNews because I don't have a web
         scraping tool yet. I can learn to do this by creating:

         Tool: hackernews_fetcher.py
         Category: network.http_read (requires your approval)

         This will take ~2 minutes. Shall I proceed?"

You: "Yes, approve network.http_read"

System: [Generating tool code...]
        [Generating tests...]
        [Testing in sandbox...]
        [Self-correcting errors...]
        [Tests passed ✓]

        "Tool installed successfully!"

        [Fetching HackerNews data...]
        [Summarizing posts...]

        "Here are the top 10 posts..."

        "I've permanently learned how to access HackerNews.
         This capability is now available for all future tasks."

[5 minutes later]

You: "Get today's HackerNews posts"

System: [Uses existing tool immediately]
        [Returns results in <10 seconds]
```

**The tool is now part of the system forever** (versioned, rollback-able).

---

## 🔒 Security & Safety

### Multi-Layer Protection

1. **Category-Based Access Control (CCAC)**
   - Hierarchical permission system
   - Approve once per category, use forever
   - Tool-specific overrides available

2. **Sandbox Isolation**
   - All generated code runs in Docker containers
   - Resource limits (2GB RAM, 2 CPU cores, 300s timeout)
   - Network isolation configurable

3. **User Approval Required**
   - First-time approval per capability category
   - Code review before installation
   - Can approve individual tools or entire categories

4. **Complete Audit Trail**
   - Every action logged with timestamp
   - Append-only, tamper-evident logs
   - Policy decisions recorded with context

5. **Versioning & Rollback**
   - All tools and adapters versioned
   - Instant rollback to previous versions
   - No permanent damage possible

---

## 🎯 Expected Growth

| Timeframe | Tools Generated | Knowledge Modules | LoRA Adapters |
|-----------|----------------|-------------------|---------------|
| Week 8    | 1-3            | 5-10              | 0-1           |
| Month 1   | 10-20          | 30-50             | 1-2           |
| Month 3   | 50-100         | 100-200           | 3-5           |
| Month 6   | 200-500        | 500-1000          | 10-15         |

**After 6 months**: System has deep expertise in your domains of interest and can handle most tasks autonomously.

---

## 📊 Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Base Model** | Qwen2.5-VL-7B-Instruct-abliterated (GGUF Q4_K_M) | Vision + reasoning + coding |
| **Inference** | llama.cpp with CUDA | Efficient VRAM usage, fast inference |
| **Vector DB** | ChromaDB | Semantic knowledge storage and retrieval |
| **Registry** | SQLite | Tool/adapter metadata and configuration |
| **Embeddings** | all-MiniLM-L6-v2 | Fast, efficient semantic embeddings |
| **Training** | Unsloth + QLoRA | Memory-efficient LoRA fine-tuning |
| **Sandbox** | Docker + nvidia-docker | Safe code execution with GPU access |
| **Language** | Python 3.11+ | Primary development language |

---

## 🧪 Testing

```bash
# Run all tests
pytest

# Run specific test suites
pytest tests/unit/           # Unit tests
pytest tests/integration/    # Integration tests
pytest tests/system/         # End-to-end tests

# With coverage report
pytest --cov=src --cov-report=html
```

---

## 📁 Project Structure

```
RAGme/
├── README.md                  # This file
├── QUICKSTART.md              # Quick setup guide
├── requirements.txt           # Python dependencies
├── setup.py                   # Package configuration
│
├── docs/                      # Documentation
│   ├── 01_DESIGN.md          # System design
│   ├── 02_ARCHITECTURE.md    # Architecture details
│   └── 03_IMPLEMENTATION.md  # Implementation guide
│
├── config/                    # Configuration files
│   ├── system.yaml           # System configuration
│   ├── policy.yaml           # Access control policies
│   └── training.yaml         # LoRA training parameters
│
├── src/                       # Source code
│   ├── core/                 # Core utilities
│   ├── intelligence/         # LLM, RAG, vision
│   │   ├── llm/             # LLM engine
│   │   ├── rag/             # RAG system
│   │   └── vision/          # Vision processing
│   ├── capability/           # Tool/knowledge/adapter generators
│   ├── execution/            # Sandboxes and executors
│   ├── orchestration/        # Agent controller
│   ├── persistence/          # Databases
│   ├── policy/               # CCAC system
│   └── ui/                   # User interfaces
│       ├── cli/             # Command-line interface
│       ├── api/             # REST API (future)
│       └── mcp/             # MCP server (future)
│
├── data/                      # Data directory (gitignored)
│   ├── models/               # GGUF models
│   ├── vector_db/            # ChromaDB storage
│   ├── registry.db           # SQLite registry
│   └── logs/                 # Application logs
│
├── tools/                     # Generated tools (runtime)
├── knowledge/                 # Knowledge modules (runtime)
├── adapters/                  # LoRA adapters (runtime)
│
├── tests/                     # Test suite
│   ├── unit/                 # Unit tests
│   ├── integration/          # Integration tests
│   └── system/               # System tests
│
└── scripts/                   # Utility scripts
    ├── download_model.sh     # Model downloader
    ├── setup_phase0.sh       # Automated setup
    └── verify_installation.py # Installation checker
```

---

## 🤝 Contributing

This is currently a single-user personal system in active development.

**Development Focus**: Follow the implementation plan in `docs/03_IMPLEMENTATION.md`.

---

## 📄 License

[To be determined]

---

## 🙏 Acknowledgments

Built on excellent open-source projects:
- **Qwen2.5-VL** by Alibaba Cloud
- **llama.cpp** by ggerganov
- **Unsloth** by unslothai
- **ChromaDB** by Chroma
- **Docker** and the container ecosystem

---

## 📬 Contact

[To be added]

---

## 🎓 Learn More

1. **Understand the Design**: Read `docs/01_DESIGN.md` for complete system specification
2. **Explore Architecture**: Read `docs/02_ARCHITECTURE.md` for component details
3. **Start Building**: Follow `docs/03_IMPLEMENTATION.md` for step-by-step guidance
4. **Quick Setup**: Follow `QUICKSTART.md` for automated installation

---

**Current Status**: Phase 1 Ready to Begin (Week 3: LLM Engine)

**Next Milestone**: First autonomous tool generation (Week 8)

---

*RAGme: The AI that grows with you, forever.*
