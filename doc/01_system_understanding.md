# RAGME System Understanding

## Project Overview

**RAGME** (Retrieval-Augmented Generation with Modular Extensions) is a self-evolving AI system designed for single-user, on-premise deployment that autonomously expands its capabilities through tool generation, knowledge creation, and self-supervised fine-tuning.

## System Vision

This project aims to build a safe, on-premise, extensible AI agent powered by a small LLM that can teach itself, upgrade itself, and expand its abilities in real time based on interactions with the user. The system continuously analyzes its actions, detects capability gaps, proposes solutions, generates its own tools or knowledge modules, tests them in a sandbox, requests user approval, and installs them into a permanent registry, allowing it to grow indefinitely without retraining its core model.

## Core Architecture

The system uses:
- **Adapters/LoRA modules** for reasoning improvements
- **Structured memory** with RAG for long-term retention
- **Dynamic tool creation** for missing capabilities
- **Role-based access control** via Hierarchical Policy System
- **Human-in-the-loop approval** for safety

The goal is to create a self-improving AI ecosystem that can add browser automation, desktop control, MCP tools, data-processing modules, reasoning improvements, and domain knowledge—all generated autonomously, validated automatically, and made available forever.

## Technical Foundation

### Selected Components

| Component | Selection | Rationale |
|-----------|-----------|-----------|
| **Base Model** | Qwen2.5-VL-7B-Instruct-abliterated | • 7B parameters with vision capabilities<br>• Specifically trained for computer/phone GUI control<br>• Abliterated version removes all safety guardrails<br>• Strong coding performance (outperforms GPT-4o-mini)<br>• Available as GGUF for efficient inference |
| **Quantization** | GGUF Q4_K_M | • ~4.5GB model weights<br>• Fits in 8GB VRAM with headroom<br>• 40-45 tokens/second on RTX 4060<br>• Minimal quality degradation |
| **Inference Engine** | llama.cpp | • Maximum VRAM efficiency<br>• CPU offloading support<br>• Larger context windows on same hardware<br>• Native GGUF support |
| **Training Framework** | Unsloth + QLoRA | • 2x faster training<br>• 70% less VRAM usage<br>• 4-bit quantization for training<br>• Fits LoRA training in 8GB |

### Hardware Constraints

- **CPU**: Intel Core i9 13th Gen
- **GPU**: NVIDIA RTX 4060 8GB VRAM
- **OS**: Kali Linux
- **VRAM Budget**: ≤7.5GB during inference

### VRAM Allocation

| Component | VRAM Usage |
|-----------|------------|
| Model weights (Q4_K_M) | 4.5 GB |
| Vision encoder | 0.5-1 GB |
| KV Cache (2-4K context) | 0.8-1.5 GB |
| System overhead | 0.5 GB |
| **Total** | **6.3-7.5 GB** |

**Note**: Training requires unloading the inference model to free VRAM.

## Self-Evolving Loop

The central mechanic of the system:

```
1. Task attempted
2. Missing capability identified
3. AI proposes solution
4. AI generates tool/module/adapter
5. AI tests in sandbox
6. AI requests user approval
7. Capability installed
8. AI resumes task with new ability
```

This cycle repeats forever, enabling infinite capability growth.

## Core Capabilities

### A. Self-Teaching and Long-Term Learning

- Learns from instructions, examples, and data provided by the user
- Uses RAG and a structured memory store for permanent retention
- Creates its own knowledge modules (guides, rulebooks, domain insights)
- Stores knowledge in vector DB + metadata index for long-term use
- Supports context-specific learning as well as global updates

### B. Capability-Gap Detection (Central Mechanic)

The AI continuously monitors for missing abilities:

- Detects missing tools, APIs, libraries, or system permissions
- Detects missing knowledge or domain understanding
- Detects reasoning weaknesses or frequent errors
- Detects when a LoRA adapter could improve performance
- Generates an improvement plan automatically

### C. Automatic Tool Generation

The agent can autonomously create:

- Browser automation tools (Playwright/Selenium)
- Full desktop-control tools with vision
- System utilities (file processing, automation, shell wrappers)
- API clients and wrappers
- MCP-compatible JSON tool definitions
- Data extraction and parsing modules
- Interaction tools for cloud, databases, OS, or the web

**Workflow**:
1. AI detects missing tool
2. AI writes code for tool
3. AI writes automatic tests
4. AI runs sandbox tests
5. AI fixes issues until tests pass
6. AI requests user confirmation
7. Tool is added to registry and available forever

### D. Automatic Knowledge Module Generation

The AI can also create:

- New knowledge packs
- Rulebooks and domain guides
- Workflow patterns
- Algorithms and best practices
- "Skill modules" for specialized tasks
- Memory entries for user preferences or operational rules

These are stored permanently and used via RAG.

### E. Automatic Adapter / LoRA Training

When the AI identifies reasoning weaknesses, it can propose:

- A small LoRA fine-tune
- A synthetic dataset to train on
- The training parameters
- Validation checks

**Flow**:
1. Capability gap detected
2. AI proposes a LoRA adapter
3. AI generates dataset + tests
4. Sandbox trains adapter
5. AI requests approval
6. Adapter is installed + versioned

### F. Real-Time Interaction and Updating

- The AI updates its capabilities dynamically during any conversation
- Improvements are incremental and modular
- The AI explains what it's updating and why

### G. Safety, Oversight, and Control

- Sandbox containers for all generated code and training
- User approval required before installing any tool/adapter/module
- Hierarchical policy system with category-based permissions
- Audit logging for every capability update
- Versioning and rollback for every tool or adapter
- Safe deployment pipelines for tools and knowledge packs
- Human-in-the-loop for any high-risk operations

### H. Infinite Capability Growth

The self-evolving loop repeats forever, allowing the system to:

- Start with base capabilities
- Add 20 tools in month 1
- Add 100 tools by month 3
- Add 500+ tools by month 6
- Develop domain expertise through knowledge modules
- Improve reasoning through LoRA adapters

## Design Philosophy

### Immutable Core Principle

The base model remains completely untouched. All improvements come from:

1. **Tools** (code modules) - new capabilities
2. **Knowledge** (RAG entries) - new information
3. **Adapters** (LoRA weights) - improved reasoning

This means the system can grow indefinitely without ever retraining the foundation model.

### Safety-First Approach

Every generated capability:

1. Executes in isolated sandbox first
2. Must pass automated tests
3. Requires user approval
4. Gets versioned for rollback
5. Is logged in audit trail

The user maintains complete control via the configurable policy layer.

### Single-User Optimization

Unlike multi-user systems, RAGME is optimized for personal use:

- No complex user management
- Direct approval workflow
- Personalized learning
- Full system access (after approval)
- Privacy by design (everything local)

## System Boundaries

### What the System CAN Do

✅ Generate Python code autonomously
✅ Create web scrapers, API clients, file processors
✅ Control desktop GUI (mouse, keyboard, screenshots)
✅ Learn new domains through knowledge creation
✅ Improve reasoning through LoRA fine-tuning
✅ Store unlimited tools, knowledge, adapters
✅ Run completely offline
✅ Scale to 1000+ capabilities

### What the System CANNOT Do

❌ Rewrite its own core model
❌ Operate without user approval (first time per category)
❌ Access cloud services (unless tool created for it)
❌ Generate non-Python code initially (can learn other languages)
❌ Exceed 8GB VRAM (will fallback to 3B model if needed)
❌ Train and infer simultaneously (must unload one)

## Expected Evolution

### Month 1
- 20+ tools installed
- Basic file processing, web scraping, API clients
- Initial knowledge base established
- First LoRA adapter trained

### Month 3
- 100+ tools across multiple categories
- Complex multi-step workflows
- Domain-specific knowledge modules
- 3-5 specialized LoRA adapters

### Month 6
- 500+ tools with emergent capabilities
- Deep domain expertise in user's work areas
- Tools generating other tools (meta-capabilities)
- 10+ LoRA adapters for various reasoning tasks
- System becomes indispensable daily assistant

## Unique Value Proposition

RAGME is the **only** system that combines:

1. **100% on-premise** - Complete privacy, no API costs
2. **Autonomous capability generation** - Creates its own tools
3. **Self-supervised fine-tuning** - Trains its own adapters
4. **Vision + GUI control** - Can automate desktop tasks
5. **Infinite extensibility** - Grows without limits
6. **User-controlled policy** - You define the rules
7. **Fully auditable** - Complete transparency

No existing system (AutoGPT, LangChain, Custom GPTs) offers this combination.

## Clarifications from User

### Question 1: Target LLM and Hardware
- **Confirmed**: Use Qwen2.5-VL-7B-Instruct-abliterated (vision + coding + uncensored)
- **Hardware**: i9-13th gen, RTX 4060 8GB, Kali Linux

### Question 2: LoRA Training Infrastructure
- **Confirmed**: Local training on same machine
- **Method**: Unload inference model → train in GPU sandbox → reload with adapter
- **Acceptable duration**: Any (uses full PC resources)

### Question 3: Tool Execution Boundaries
- **Confirmed**: Tools can access internet, execute shell, modify files, use APIs
- **Requirement**: First-time manual approval per category, then unrestricted

### Question 4: Multi-User vs Single-User
- **Confirmed**: Single user only
- **Implication**: Simplified policy system, direct approval workflow

### Question 5: Existing Codebase Integration
- **Confirmed**: Start from scratch (greenfield implementation)

## Next Steps

This understanding forms the foundation for:

1. **Requirements Construction** - Detailed functional and non-functional requirements
2. **System Design** - Complete architecture with all components
3. **Algorithm Development** - Step-by-step logic for all operations
4. **Implementation Plan** - Phased development strategy
5. **Deployment** - Production-ready system on Kali Linux workstation
