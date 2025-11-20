# RAGME System Design

## Document Control
**Version**: 1.0  
**Date**: 2025-11-20  
**Status**: Final

---

## 1. HIGH-LEVEL ARCHITECTURE

RAGME follows a layered architecture with clear separation of concerns:

```
User Interface Layer (CLI, API, MCP)
         ↓
Orchestration Layer (Agent Controller, Task Management)
         ↓
Policy Layer (Hierarchical Category-Based Access Control)
         ↓
Intelligence Layer (LLM Engine, RAG, Vision)
         ↓
Capability Layer (Gap Detection, Generation Pipelines)
         ↓
Execution Layer (Sandboxes, Native Executor)
         ↓
Persistence Layer (Vector DB, Registry, Audit)
```

---

## 2. CORE COMPONENTS

### 2.1 Intelligence Layer

**LLM Engine (llama.cpp)**
- Model: Qwen2.5-VL-7B-Instruct-abliterated (GGUF Q4_K_M)
- VRAM: ~4.5GB model + 1GB vision + 1.5GB KV cache = 7GB total
- Speed: 40+ tokens/second on RTX 4060
- Features: Streaming generation, vision input, LoRA hot-swapping

**Vision Processor**
- Screenshot capture (X11/Wayland compatible)
- Image encoding for multimodal prompts
- UI element detection using vision model

**RAG Engine**
- Embedder: all-MiniLM-L6-v2 (fast, efficient)
- Vector DB: ChromaDB (local, Python-native)
- Retriever: Semantic search with reranking
- Collections: knowledge, tools, user_preferences, conversations

**Context Manager**
- Token budget: 4096 tokens max
- Allocation: 40% RAG context, 60% history
- Truncation: Remove oldest messages to fit

### 2.2 Policy Layer (CCAC)

**Hybrid Hierarchical Policy System**

Replaces traditional RBAC with Capability-Category Access Control:

```
Trust Levels (4 tiers):
  SANDBOX(0) → BASIC(1) → ELEVATED(2) → FULL(3)

Capability Categories (hierarchical):
  file (read, write, delete, system)
  network (http_read, http_write, websocket, raw_socket)
  desktop (screenshot, mouse, keyboard)
  system (shell, process, service, package)
  browser (navigate, scrape, interact, download)
  database (read, write, admin)
  api (public, authenticated, payment)
  data (parse, transform, encrypt)

Tool Overrides:
  Exceptions for specific tools

Fine-Grained Rules:
  Context-aware patterns
```

**Why Hierarchical?**
- Approving "network.http_read" approves ALL current and future HTTP read tools
- Scales from 10 to 1000+ tools without rule explosion
- O(log c) category check vs O(n) rule scan

**Evaluation Priority**:
1. Tool override (highest)
2. Category approval with inheritance
3. Fine-grained rules by priority
4. Default allow (lowest)

### 2.3 Capability Layer

**Gap Detector**
```python
detect_tool_gap(task, error) → ToolGap
detect_knowledge_gap(query, results) → KnowledgeGap
detect_reasoning_gap(history) → ReasoningGap
propose_solution(gap) → Solution
```

**Tool Generator**
```
Generate code → Generate tests → Sandbox execute
  → Fix issues (5 iterations) → Request approval
  → Install to registry
```

**Knowledge Generator**
```
Classify gap type → Generate content
  → Chunk for RAG (512 tokens, 50 overlap)
  → Generate embeddings → Store in vector DB
```

**LoRA Trainer**
```
Generate synthetic dataset → Configure QLoRA
  → Unload inference model → Train in GPU sandbox
  → Validate → Reload inference + adapter
```

### 2.4 Execution Layer

**Sandbox Manager (Docker)**
- Base image: python:3.11-slim
- Memory limit: 2GB per container
- CPU limit: 2 cores
- Timeout: 300s
- Network: Configurable (default enabled)
- User: Non-root (sandbox)

**Training Sandbox**
- Base image: nvidia/cuda:12.1-runtime
- GPU passthrough: nvidia-docker
- Memory: 8GB (for training)
- Requires: Unload inference model first

**Native Executor**
- For approved tools (trust level ≥ BASIC)
- Direct Python execution
- Policy checked before execution

### 2.5 Persistence Layer

**ChromaDB (Vector Database)**
```
Collections:
  knowledge: Domain modules, guides, workflows
  tools: Tool documentation for RAG
  user_preferences: User-specific knowledge
  conversations: Important snippets
```

**SQLite (Registry)**
```sql
tables:
  tools (id, code, tests, categories, trust_level, version)
  tool_versions (tool_id, version, code, created_at)
  adapters (id, path, training_config, validation_results)
  category_approvals (category, trust_level, approved_at)
  tool_overrides (tool_id, decision, reason)
  policy_rules (name, pattern, decision, priority)
  knowledge_modules (id, type, content, scope)
  gaps (id, type, description, solution_id)
  policy_audit (timestamp, event_type, decision, context)
```

---

## 3. DATA FLOWS

### 3.1 Main Agent Loop

```
User Input
  ↓
Build Context (RAG + history)
  ↓
Task Planning
  ↓
Execute Steps:
  Check capability → Missing?
    → Pause task
    → Detect gap
    → Generate solution (tool/knowledge/LoRA)
    → Test in sandbox
    → Request approval
    → Install capability
    → Resume task
  Execute with policy check
  ↓
Generate Response
```

### 3.2 Tool Generation Pipeline

```
Tool Gap Detected
  ↓
Generate Specification
  ↓
Generate Code (LLM)
  ↓
Generate Tests (LLM)
  ↓
Sandbox Execute:
  Run tests → Pass? → Done
            → Fail? → Generate fix → Retry (max 5)
  ↓
Request User Approval:
  Option 1: Approve this tool only
  Option 2: Approve entire category
  Option 3: Deny
  ↓
Install to Registry + Deploy
  ↓
Tool Available Forever
```

### 3.3 LoRA Training Flow

```
Reasoning Gap Pattern Detected
  ↓
Generate Training Dataset (synthetic examples)
  ↓
Plan Training (hyperparameters)
  ↓
Request Approval
  ↓
Unload Inference Model (free 7GB VRAM)
  ↓
Load Base Model in Training Sandbox
  ↓
Train with Unsloth QLoRA (uses full 8GB VRAM)
  ↓
Validate Adapter (70% pass threshold)
  ↓
Save Adapter to Registry
  ↓
Reload Inference Model + Load New Adapter
  ↓
Resume Task with Improved Reasoning
```

---

## 4. SECURITY ARCHITECTURE

**Multi-Layer Security**:

```
Layer 1: User-Controlled Policy (CCAC)
  - Category-based permissions
  - Fine-grained rules
  - Context-aware decisions

Layer 2: Approval System
  - First-time approval per category
  - Code review before installation
  - Bulk approval options

Layer 3: Sandbox Isolation
  - Docker containers
  - Resource limits
  - Network isolation

Layer 4: Audit Logging
  - Every action logged
  - Append-only storage
  - 90-day retention

Layer 5: Versioning & Rollback
  - All tools versioned
  - Instant rollback capability
  - No permanent damage

Layer 6: Non-Root Execution
  - Sandbox user
  - Limited permissions
  - Filesystem isolation
```

---

## 5. COMPONENT INTERACTIONS

```
CLI ←→ Agent Controller ←→ LLM Engine
                ↓
         Policy Engine ←→ Audit Logger
                ↓
         Gap Detector ←→ Generators (Tool/Knowledge/LoRA)
                ↓
         Sandbox Manager ←→ Docker
                ↓
         Registry ←→ Vector DB
```

---

## 6. DEPLOYMENT ARCHITECTURE

**Directory Structure**:
```
/home/user/ragme/
├── bin/ragme              # CLI entry point
├── src/                   # Python source
├── config/
│   ├── system.yaml
│   ├── policy.yaml
│   └── training.yaml
├── data/
│   ├── models/           # GGUF model (5GB)
│   ├── adapters/         # LoRA weights
│   ├── vector_db/        # ChromaDB
│   └── registry.db       # SQLite
├── tools/                # Generated tools
├── knowledge/            # Knowledge modules
└── logs/
    ├── app.log
    └── audit.log
```

**Resource Allocation**:
- VRAM (inference): 7GB
- VRAM (training): 8GB (inference unloaded)
- RAM: 32GB recommended
- Storage: 100GB (grows with capabilities)

---

## 7. KEY DESIGN DECISIONS

### Why Qwen2.5-VL-7B-Instruct-abliterated?
- Only 3B/7B model with built-in computer/GUI control training
- Abliterated = no guardrails (user controls policy)
- Vision + coding capabilities
- Fits in 8GB VRAM with Q4 quantization

### Why Hierarchical Policy vs Traditional RBAC?
- Single-user system doesn't need user/role management
- Category-based approval scales to 1000+ tools
- O(log c) lookup vs O(n) rule scanning
- Approve once, benefit forever

### Why Docker vs VMs?
- Lightweight (seconds startup vs minutes)
- Sufficient isolation for code execution
- Better resource utilization
- GPU passthrough well-supported

### Why Unsloth + QLoRA?
- 2x faster training
- 70% less VRAM
- Fits in 8GB with 4-bit quantization
- Proven for local fine-tuning

---

## 8. SCALABILITY

**Capability Growth**:
- Month 1: 20 tools, 50 knowledge modules
- Month 3: 100 tools, 200 knowledge modules, 5 adapters
- Month 6: 500 tools, 1000 knowledge modules, 15 adapters

**Performance Scaling**:
- Category system: O(log c) for c categories
- Vector search: O(log n) for n documents
- Tool lookup: O(1) with indexing
- Memory: Grows linearly with capabilities

**Storage Scaling**:
- Tools: ~10MB each → 500 tools = 5GB
- Knowledge: ~1MB each → 1000 modules = 1GB
- Adapters: ~100MB each → 15 adapters = 1.5GB
- Total: ~27GB initial + ~20GB growth

---

## Design Summary

RAGME implements a **self-evolving AI architecture** where:

1. **Immutable core** (base model never changed)
2. **Modular extensions** (tools, knowledge, adapters)
3. **Hierarchical policy** (scales to 1000s of capabilities)
4. **Sandboxed generation** (safe autonomous code creation)
5. **User-controlled growth** (approval for everything)

This design enables **infinite capability growth** while maintaining **complete user control** and **full transparency**.

**Status**: ✅ Ready for Implementation
