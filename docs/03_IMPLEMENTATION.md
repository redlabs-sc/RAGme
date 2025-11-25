# Phase 1 Implementation Guide (Weeks 3-8)

**Goal**: Build a working self-evolving AI system that can autonomously generate its first tool

**Status**: Ready to begin
**Prerequisites**: Phase 0 complete ✅

---

## Overview

Phase 1 delivers the **minimum viable cognitive partner**:
- Single LLM with vision (Qwen2.5-VL-7B)
- RAG-based memory (ChromaDB)
- Policy enforcement (CCAC)
- Autonomous tool generation
- Full self-evolution loop

**Timeline**: 6 weeks (Weeks 3-8)
**Complexity**: Moderate (production-ready components)
**Risk**: Low (proven technologies)

---

## Week 3-4: LLM Engine (Foundation)

### Goals
- Get Qwen2.5-VL-7B running locally
- Achieve 35+ tokens/second inference
- Stay under 7.5GB VRAM usage
- Process vision inputs (screenshots)
- Implement chain-of-thought prompting

### Tasks

#### Task 3.1: Install llama.cpp with CUDA Support

```bash
# 1. Clone llama.cpp
cd ~/projects
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# 2. Build with CUDA
make clean
make LLAMA_CUDA=1 -j$(nproc)

# 3. Verify GPU support
./main --version
# Should show CUDA support enabled

# 4. Test with small model
./main -m path/to/small-model.gguf -p "Hello" -n 10
```

**Success Criteria**:
- ✅ Compilation succeeds
- ✅ CUDA detected
- ✅ Test inference works

**Time Estimate**: 2 hours

---

#### Task 3.2: Download Qwen2.5-VL-7B Model

```bash
# 1. Install huggingface-cli
pip install huggingface-hub

# 2. Download GGUF model (Q4_K_M quantization)
huggingface-cli download \
  Qwen/Qwen2.5-VL-7B-Instruct-GGUF \
  qwen2.5-vl-7b-instruct-q4_k_m.gguf \
  --local-dir ~/RAGme/data/models

# 3. Verify download
ls -lh ~/RAGme/data/models/*.gguf
# Should show ~4.5-5GB file
```

**Fallback**: If official GGUF unavailable, convert from HF:
```bash
# Download base model
git lfs install
git clone https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct

# Convert to GGUF
python llama.cpp/convert.py \
  Qwen2.5-VL-7B-Instruct \
  --outfile qwen2.5-vl-7b-instruct-f16.gguf \
  --outtype f16

# Quantize to Q4_K_M
./llama.cpp/quantize \
  qwen2.5-vl-7b-instruct-f16.gguf \
  qwen2.5-vl-7b-instruct-q4_k_m.gguf \
  Q4_K_M
```

**Success Criteria**:
- ✅ Model file exists (~5GB)
- ✅ Checksum validates

**Time Estimate**: 1-3 hours (mostly download time)

---

#### Task 3.3: Python Bindings (llama-cpp-python)

```bash
# 1. Install with CUDA support
CMAKE_ARGS="-DLLAMA_CUDA=1" pip install llama-cpp-python

# 2. Test basic inference
python3 << 'EOF'
from llama_cpp import Llama

llm = Llama(
    model_path="data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf",
    n_ctx=4096,
    n_gpu_layers=-1,  # Offload all layers to GPU
    verbose=True
)

response = llm("Hello, world!", max_tokens=50)
print(response)
EOF
```

**Success Criteria**:
- ✅ Loads model to GPU
- ✅ Generates text
- ✅ VRAM usage < 7GB

**Time Estimate**: 1 hour

---

#### Task 3.4: Implement LLM Engine Module

Create `src/intelligence/llm/engine.py`:

```python
from llama_cpp import Llama
from typing import Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class LLMEngine:
    """Qwen2.5-VL-7B inference engine with LoRA support"""

    def __init__(
        self,
        model_path: str,
        n_ctx: int = 4096,
        n_gpu_layers: int = -1,
        verbose: bool = False
    ):
        self.model_path = model_path
        self.n_ctx = n_ctx
        self.llm = None
        self.current_adapters = []
        self._load_model(n_gpu_layers, verbose)

    def _load_model(self, n_gpu_layers: int, verbose: bool):
        """Load model into memory"""
        logger.info(f"Loading model from {self.model_path}")
        self.llm = Llama(
            model_path=self.model_path,
            n_ctx=self.n_ctx,
            n_gpu_layers=n_gpu_layers,
            verbose=verbose
        )
        logger.info("Model loaded successfully")

    def generate(
        self,
        prompt: str,
        max_tokens: int = 512,
        temperature: float = 0.7,
        stop: Optional[list] = None,
        stream: bool = False
    ) -> str:
        """Generate text from prompt"""
        response = self.llm(
            prompt,
            max_tokens=max_tokens,
            temperature=temperature,
            stop=stop or [],
            stream=stream,
            echo=False
        )

        if stream:
            return response  # Generator for streaming

        return response['choices'][0]['text']

    def load_adapter(self, adapter_path: str):
        """Load LoRA adapter (Phase 1: stub, implement in Week 7)"""
        logger.info(f"Loading adapter: {adapter_path}")
        # TODO: Implement LoRA loading
        self.current_adapters.append(adapter_path)

    def unload_adapters(self):
        """Unload all LoRA adapters"""
        logger.info("Unloading adapters")
        self.current_adapters = []

    def get_stats(self) -> Dict[str, Any]:
        """Get model statistics"""
        return {
            "model": self.model_path,
            "context_size": self.n_ctx,
            "adapters_loaded": len(self.current_adapters),
            "loaded": self.llm is not None
        }
```

**Test**:
```python
# test_llm_engine.py
from src.intelligence.llm.engine import LLMEngine

engine = LLMEngine(model_path="data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf")
response = engine.generate("Explain Python list comprehensions in one sentence:")
print(response)
print(engine.get_stats())
```

**Success Criteria**:
- ✅ Model loads successfully
- ✅ Generates coherent text
- ✅ Stats reporting works
- ✅ VRAM < 7GB

**Time Estimate**: 4 hours

---

#### Task 3.5: Vision Processing Pipeline

Create `src/intelligence/vision/processor.py`:

```python
import base64
from PIL import Image
from io import BytesIO
from typing import Union, Optional
import logging

logger = logging.getLogger(__name__)

class VisionProcessor:
    """Process images for multimodal LLM input"""

    def __init__(self, max_size: int = 1024):
        self.max_size = max_size

    def process_image(
        self,
        image_source: Union[str, Image.Image],
        resize: bool = True
    ) -> str:
        """
        Process image for LLM consumption

        Args:
            image_source: File path or PIL Image
            resize: Whether to resize to max_size

        Returns:
            Base64 encoded image string
        """
        # Load image
        if isinstance(image_source, str):
            image = Image.open(image_source)
        else:
            image = image_source

        # Resize if needed
        if resize:
            image = self._resize_image(image)

        # Convert to base64
        buffered = BytesIO()
        image.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode()

        logger.info(f"Processed image: {image.size}")
        return img_str

    def _resize_image(self, image: Image.Image) -> Image.Image:
        """Resize image maintaining aspect ratio"""
        if max(image.size) <= self.max_size:
            return image

        ratio = self.max_size / max(image.size)
        new_size = tuple(int(dim * ratio) for dim in image.size)
        return image.resize(new_size, Image.LANCZOS)

    def capture_screenshot(self, region: Optional[tuple] = None) -> Image.Image:
        """Capture screenshot (full screen or region)"""
        try:
            from PIL import ImageGrab
            screenshot = ImageGrab.grab(bbox=region)
            logger.info(f"Screenshot captured: {screenshot.size}")
            return screenshot
        except Exception as e:
            logger.error(f"Screenshot failed: {e}")
            raise
```

**Test**:
```python
# test_vision.py
from src.intelligence.vision.processor import VisionProcessor

processor = VisionProcessor()

# Test with image file
encoded = processor.process_image("test_image.png")
print(f"Encoded length: {len(encoded)}")

# Test screenshot
screenshot = processor.capture_screenshot()
encoded_screenshot = processor.process_image(screenshot)
print(f"Screenshot encoded: {len(encoded_screenshot)}")
```

**Success Criteria**:
- ✅ Loads and processes images
- ✅ Resizes correctly
- ✅ Base64 encoding works
- ✅ Screenshots work

**Time Estimate**: 3 hours

---

#### Task 3.6: Chain-of-Thought Prompt Templates

Create `src/intelligence/llm/prompts.py`:

```python
"""Prompt templates for chain-of-thought reasoning"""

SYSTEM_PROMPT = """You are an autonomous AI assistant that can teach itself new capabilities.

Your core abilities:
1. Detect when you lack a capability to complete a task
2. Propose solutions (generate tool, create knowledge, train adapter)
3. Generate and test solutions autonomously
4. Request user approval before installation
5. Explain your reasoning transparently

When you encounter something you cannot do:
1. Explain what you cannot do and why
2. Propose a specific solution
3. Estimate time and resources needed
4. Wait for approval
5. Execute and install if approved

Always use <thinking> tags to show your step-by-step reasoning process.
Be precise, honest, and transparent."""

USER_TASK_TEMPLATE = """<|im_start|>system
{system_prompt}<|im_end|>
<|im_start|>user
{user_message}<|im_end|>
<|im_start|>assistant
<thinking>
Let me analyze this task step by step:
"""

TOOL_GENERATION_TEMPLATE = """<|im_start|>system
{system_prompt}

You are now in TOOL GENERATION mode.
Task: Generate Python code for the following tool.

Requirements:
- Pure Python 3.11+
- No external dependencies if possible
- Include docstrings
- Handle errors gracefully
- Return results as dictionaries
<|im_end|>
<|im_start|>user
Generate a tool with the following specification:

{tool_spec}
<|im_end|>
<|im_start|>assistant
<thinking>
Breaking down the tool requirements:
"""

def format_prompt(template: str, **kwargs) -> str:
    """Format prompt template with variables"""
    return template.format(**kwargs)
```

**Test**:
```python
# test_prompts.py
from src.intelligence.llm.prompts import *

prompt = format_prompt(
    USER_TASK_TEMPLATE,
    system_prompt=SYSTEM_PROMPT,
    user_message="Scrape the top posts from HackerNews"
)
print(prompt)
```

**Success Criteria**:
- ✅ Templates defined
- ✅ Formatting works
- ✅ Produces valid chat format

**Time Estimate**: 2 hours

---

#### Task 3.7: Integration Test

Create `tests/test_llm_integration.py`:

```python
"""Integration test for LLM engine"""
from src.intelligence.llm.engine import LLMEngine
from src.intelligence.llm.prompts import *

def test_llm_engine():
    """Test complete LLM engine pipeline"""

    # Initialize engine
    engine = LLMEngine(
        model_path="data/models/qwen2.5-vl-7b-instruct-q4_k_m.gguf",
        n_ctx=4096
    )

    # Test basic generation
    prompt = format_prompt(
        USER_TASK_TEMPLATE,
        system_prompt=SYSTEM_PROMPT,
        user_message="Write a Python function to check if a number is prime."
    )

    response = engine.generate(prompt, max_tokens=512)
    print("Response:", response)

    # Check stats
    stats = engine.get_stats()
    print("Stats:", stats)

    assert stats['loaded'] == True
    assert len(response) > 0
    print("✅ LLM Engine test passed")

if __name__ == "__main__":
    test_llm_engine()
```

**Run**:
```bash
python tests/test_llm_integration.py
```

**Success Criteria**:
- ✅ Model loads
- ✅ Generates reasonable code
- ✅ Shows chain-of-thought reasoning
- ✅ VRAM < 7.5GB
- ✅ Speed ≥ 35 tokens/second

**Time Estimate**: 2 hours

---

### Week 3-4 Deliverables

- ✅ llama.cpp installed with CUDA
- ✅ Qwen2.5-VL-7B model downloaded
- ✅ Python bindings working
- ✅ LLM engine module implemented
- ✅ Vision processing pipeline
- ✅ Prompt templates defined
- ✅ Integration test passing

**Total Time**: ~20 hours over 2 weeks

---

## Week 4-5: RAG System (Memory)

### Goals
- Setup ChromaDB for knowledge storage
- Implement semantic search
- Create knowledge chunking pipeline
- Test retrieval accuracy

### Tasks

#### Task 4.1: Install ChromaDB

```bash
# Install ChromaDB
pip install chromadb

# Test installation
python3 << 'EOF'
import chromadb
client = chromadb.Client()
print("ChromaDB version:", chromadb.__version__)
EOF
```

**Success Criteria**:
- ✅ ChromaDB installs
- ✅ Client initializes

**Time Estimate**: 30 minutes

---

#### Task 4.2: Implement RAG Engine

Create `src/intelligence/rag/engine.py`:

```python
import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer
from typing import List, Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

class RAGEngine:
    """Retrieval-Augmented Generation engine using ChromaDB"""

    COLLECTIONS = ["knowledge", "tools", "conversations", "user_preferences"]

    def __init__(
        self,
        persist_directory: str = "data/vector_db",
        embedding_model: str = "all-MiniLM-L6-v2"
    ):
        self.persist_directory = persist_directory

        # Initialize ChromaDB client
        self.client = chromadb.Client(Settings(
            chroma_db_impl="duckdb+parquet",
            persist_directory=persist_directory
        ))

        # Initialize embedding model
        logger.info(f"Loading embedding model: {embedding_model}")
        self.embedder = SentenceTransformer(embedding_model)

        # Create collections
        self.collections = {}
        for collection_name in self.COLLECTIONS:
            self.collections[collection_name] = self.client.get_or_create_collection(
                name=collection_name,
                metadata={"description": f"{collection_name} storage"}
            )

        logger.info(f"RAG engine initialized with {len(self.COLLECTIONS)} collections")

    def add_knowledge(
        self,
        documents: List[str],
        metadatas: List[Dict[str, Any]],
        collection: str = "knowledge"
    ) -> List[str]:
        """Add documents to knowledge base"""

        # Generate embeddings
        embeddings = self.embedder.encode(documents).tolist()

        # Generate IDs
        ids = [f"{collection}_{i}" for i in range(len(documents))]

        # Add to collection
        self.collections[collection].add(
            documents=documents,
            embeddings=embeddings,
            metadatas=metadatas,
            ids=ids
        )

        logger.info(f"Added {len(documents)} documents to {collection}")
        return ids

    def search(
        self,
        query: str,
        collection: str = "knowledge",
        n_results: int = 5,
        filter_metadata: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """Semantic search in collection"""

        # Generate query embedding
        query_embedding = self.embedder.encode([query])[0].tolist()

        # Search
        results = self.collections[collection].query(
            query_embeddings=[query_embedding],
            n_results=n_results,
            where=filter_metadata
        )

        logger.info(f"Search returned {len(results['documents'][0])} results")
        return {
            "documents": results['documents'][0],
            "metadatas": results['metadatas'][0],
            "distances": results['distances'][0]
        }

    def get_stats(self) -> Dict[str, int]:
        """Get collection statistics"""
        stats = {}
        for name, collection in self.collections.items():
            stats[name] = collection.count()
        return stats
```

**Test**:
```python
# test_rag.py
from src.intelligence.rag.engine import RAGEngine

rag = RAGEngine()

# Add test documents
docs = [
    "Python is a high-level programming language.",
    "List comprehensions provide concise syntax for lists.",
    "Functions in Python can return multiple values."
]

metadatas = [
    {"domain": "python", "type": "general"},
    {"domain": "python", "type": "syntax"},
    {"domain": "python", "type": "functions"}
]

ids = rag.add_knowledge(docs, metadatas)
print(f"Added {len(ids)} documents")

# Search
results = rag.search("How do I create lists in Python?", n_results=2)
for doc, meta, dist in zip(results['documents'], results['metadatas'], results['distances']):
    print(f"\n[Distance: {dist:.3f}] {doc}")
    print(f"Metadata: {meta}")

# Stats
print("\nStats:", rag.get_stats())
```

**Success Criteria**:
- ✅ ChromaDB collections created
- ✅ Documents added successfully
- ✅ Search returns relevant results
- ✅ Metadata filtering works

**Time Estimate**: 6 hours

---

#### Task 4.3: Knowledge Chunking Pipeline

Create `src/intelligence/rag/chunker.py`:

```python
"""Text chunking for RAG"""
from typing import List, Dict, Any
import re

class KnowledgeChunker:
    """Chunk text for optimal RAG performance"""

    def __init__(self, chunk_size: int = 512, overlap: int = 50):
        self.chunk_size = chunk_size
        self.overlap = overlap

    def chunk_text(
        self,
        text: str,
        metadata: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """
        Chunk text with overlap

        Returns:
            List of {"text": str, "metadata": dict}
        """
        # Clean text
        text = self._clean_text(text)

        # Split into sentences
        sentences = self._split_sentences(text)

        # Build chunks
        chunks = []
        current_chunk = []
        current_size = 0

        for sentence in sentences:
            sentence_size = len(sentence.split())

            if current_size + sentence_size > self.chunk_size and current_chunk:
                # Save current chunk
                chunk_text = " ".join(current_chunk)
                chunks.append({
                    "text": chunk_text,
                    "metadata": {**metadata, "chunk_id": len(chunks)}
                })

                # Start new chunk with overlap
                overlap_sentences = current_chunk[-self.overlap:] if len(current_chunk) > self.overlap else current_chunk
                current_chunk = overlap_sentences
                current_size = sum(len(s.split()) for s in current_chunk)

            current_chunk.append(sentence)
            current_size += sentence_size

        # Add final chunk
        if current_chunk:
            chunk_text = " ".join(current_chunk)
            chunks.append({
                "text": chunk_text,
                "metadata": {**metadata, "chunk_id": len(chunks)}
            })

        return chunks

    def _clean_text(self, text: str) -> str:
        """Clean and normalize text"""
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text)
        return text.strip()

    def _split_sentences(self, text: str) -> List[str]:
        """Split text into sentences"""
        # Simple sentence splitting (improve with nltk if needed)
        sentences = re.split(r'(?<=[.!?])\s+', text)
        return [s.strip() for s in sentences if s.strip()]
```

**Test**:
```python
# test_chunker.py
from src.intelligence.rag.chunker import KnowledgeChunker

chunker = KnowledgeChunker(chunk_size=50, overlap=10)

text = """
Python is a high-level, interpreted programming language.
It emphasizes code readability and simplicity.
Python supports multiple programming paradigms.
It has a large standard library.
"""

chunks = chunker.chunk_text(text, {"domain": "python", "source": "test"})

for i, chunk in enumerate(chunks):
    print(f"\nChunk {i}:")
    print(f"Text: {chunk['text']}")
    print(f"Metadata: {chunk['metadata']}")
```

**Success Criteria**:
- ✅ Text splits into chunks
- ✅ Overlap preserved
- ✅ Metadata attached
- ✅ Chunk size respected

**Time Estimate**: 3 hours

---

### Week 4-5 Deliverables

- ✅ ChromaDB installed and configured
- ✅ RAG engine implemented
- ✅ Embedding generation working
- ✅ Semantic search functional
- ✅ Knowledge chunking pipeline
- ✅ Integration tests passing

**Total Time**: ~12 hours over 1-2 weeks

---

## Week 5-6: Policy Layer (Safety)

### Goals
- Implement Category-Based Access Control (CCAC)
- Build approval workflow
- Setup Docker sandbox
- Create audit logging

### Tasks

#### Task 5.1: Implement CCAC System

Create `src/policy/ccac.py`:

```python
"""Category-Based Access Control (CCAC)"""
from enum import IntEnum
from typing import Dict, Optional, List
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)

class TrustLevel(IntEnum):
    """Trust levels for capabilities"""
    SANDBOX = 0      # Isolated execution only
    BASIC = 1        # Read-only operations
    ELEVATED = 2     # Write operations
    FULL = 3         # System-level access

@dataclass
class Category:
    """Capability category"""
    name: str
    parent: Optional[str]
    trust_level: TrustLevel
    approved: bool = False

class CCACEngine:
    """Hierarchical category-based access control"""

    def __init__(self, policy_config: Dict):
        self.categories = self._load_categories(policy_config)
        self.approvals = {}  # category -> approved
        self.tool_overrides = {}  # tool_id -> decision

    def _load_categories(self, config: Dict) -> Dict[str, Category]:
        """Load category hierarchy from config"""
        categories = {}

        for cat_name, cat_config in config.get('categories', {}).items():
            for subcat_name, trust_level in cat_config.items():
                full_name = f"{cat_name}.{subcat_name}"
                categories[full_name] = Category(
                    name=full_name,
                    parent=cat_name,
                    trust_level=TrustLevel[trust_level.upper()]
                )

        return categories

    def check_permission(
        self,
        category: str,
        tool_id: Optional[str] = None
    ) -> bool:
        """Check if category/tool is approved"""

        # Tool-specific override
        if tool_id and tool_id in self.tool_overrides:
            decision = self.tool_overrides[tool_id]
            logger.info(f"Tool override: {tool_id} -> {decision}")
            return decision

        # Category approval (with inheritance)
        if category in self.approvals:
            logger.info(f"Category approved: {category}")
            return self.approvals[category]

        # Check parent category
        if '.' in category:
            parent = category.split('.')[0]
            if parent in self.approvals:
                logger.info(f"Parent category approved: {parent}")
                return self.approvals[parent]

        # Default: deny
        logger.warning(f"Permission denied: {category}")
        return False

    def approve_category(self, category: str):
        """Approve a category"""
        self.approvals[category] = True
        logger.info(f"Category approved: {category}")

    def approve_tool(self, tool_id: str):
        """Approve specific tool"""
        self.tool_overrides[tool_id] = True
        logger.info(f"Tool approved: {tool_id}")

    def deny_tool(self, tool_id: str):
        """Deny specific tool"""
        self.tool_overrides[tool_id] = False
        logger.info(f"Tool denied: {tool_id}")

    def get_stats(self) -> Dict:
        """Get policy statistics"""
        return {
            "categories": len(self.categories),
            "approved_categories": len(self.approvals),
            "tool_overrides": len(self.tool_overrides)
        }
```

**Test**:
```python
# test_ccac.py
from src.policy.ccac import CCACEngine, TrustLevel

config = {
    "categories": {
        "file": {
            "read": "BASIC",
            "write": "ELEVATED",
            "delete": "ELEVATED"
        },
        "network": {
            "http_read": "BASIC",
            "http_write": "ELEVATED"
        }
    }
}

ccac = CCACEngine(config)

# Test: Not approved initially
assert ccac.check_permission("file.read") == False

# Approve category
ccac.approve_category("file")

# Test: Child categories inherited
assert ccac.check_permission("file.read") == True
assert ccac.check_permission("file.write") == True

# Test: Tool override
ccac.deny_tool("dangerous_tool")
assert ccac.check_permission("file.write", tool_id="dangerous_tool") == False

print("✅ CCAC tests passed")
print("Stats:", ccac.get_stats())
```

**Success Criteria**:
- ✅ Categories load from config
- ✅ Approval system works
- ✅ Inheritance works (parent → child)
- ✅ Tool overrides work

**Time Estimate**: 6 hours

---

*(Continue with remaining tasks 5.2-5.4, Week 6, Week 7, Week 8...)*

---

## Quick Reference: Complete Timeline

```
Week 3-4: LLM Engine        [✅ Ready to implement]
Week 4-5: RAG System        [📋 Detailed above]
Week 5-6: Policy Layer      [📋 Detailed above]
Week 6:   Gap Detection     [📋 See full guide]
Week 7:   Tool Generation   [📋 See full guide]
Week 8:   Integration       [📋 See full guide]
```

**Total Implementation Time**: 120-150 hours over 6 weeks

---

## Success Criteria (Phase 1 Complete)

The system is **Phase 1 complete** when:

1. ✅ User can request: "Download top HackerNews posts"
2. ✅ System detects missing web scraping capability
3. ✅ System proposes generating a tool
4. ✅ System generates code + tests autonomously
5. ✅ Tests pass (or system self-corrects via Reflexion)
6. ✅ System requests user approval
7. ✅ User approves category or specific tool
8. ✅ Tool installs to registry
9. ✅ Tool executes and completes task
10. ✅ Tool is available forever (versioned)

**End-to-end time**: < 5 minutes from request to completion

---

## Next Steps

1. **Start Week 3**: Follow Task 3.1 (Install llama.cpp)
2. **Track progress**: Use this guide as checklist
3. **Document issues**: Note any deviations or problems
4. **Test thoroughly**: Each task has success criteria

**Ready to begin? Start with Task 3.1** ⬆️

