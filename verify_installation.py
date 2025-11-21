#!/usr/bin/env python3
"""
RAGME Installation Verification Script
Checks all Phase 0 components are correctly installed
"""

import os
import sys
import sqlite3
from pathlib import Path

# Colors for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'

def log_success(msg):
    print(f"{Colors.GREEN}✓{Colors.END} {msg}")

def log_error(msg):
    print(f"{Colors.RED}✗{Colors.END} {msg}")

def log_warning(msg):
    print(f"{Colors.YELLOW}⚠{Colors.END} {msg}")

def log_info(msg):
    print(f"{Colors.BLUE}ℹ{Colors.END} {msg}")

def check_python_version():
    """Check Python version is 3.9+"""
    version = sys.version_info
    if version.major >= 3 and version.minor >= 9:
        log_success(f"Python version: {version.major}.{version.minor}.{version.micro}")
        return True
    else:
        log_error(f"Python version: {version.major}.{version.minor}.{version.micro} (need 3.9+)")
        return False

def check_llama_cpp():
    """Check llama-cpp-python is installed"""
    try:
        from llama_cpp import Llama
        import llama_cpp
        log_success("llama-cpp-python: Installed")

        # Check for CUDA support
        try:
            # Try to check CUDA availability
            if hasattr(llama_cpp.llama_cpp, 'GGML_USE_CUDA'):
                log_success("  CUDA support: Enabled")
            else:
                log_warning("  CUDA support: Not detected (CPU-only)")
        except:
            log_warning("  CUDA support: Cannot verify")

        return True
    except ImportError as e:
        log_error(f"llama-cpp-python: Not installed ({e})")
        return False

def check_dependencies():
    """Check critical dependencies"""
    deps = {
        'chromadb': 'ChromaDB',
        'pynput': 'Desktop control',
        'playwright': 'Browser automation',
        'fastapi': 'REST API',
        'rich': 'CLI UI',
        'pytest': 'Testing',
        'peft': 'LoRA training',
        'transformers': 'Transformers',
    }

    all_ok = True
    for module, name in deps.items():
        try:
            __import__(module)
            log_success(f"{name}: Installed")
        except ImportError:
            log_error(f"{name}: Missing")
            all_ok = False

    return all_ok

def check_model_file():
    """Check model file exists"""
    model_path = Path("data/models/qwen2.5-vl-7b-instruct-abliterated-q4_k_m.gguf")

    if model_path.exists():
        size_gb = model_path.stat().st_size / (1024**3)
        log_success(f"Model file: {model_path} ({size_gb:.2f} GB)")

        if size_gb < 4.0:
            log_warning(f"  Model file seems small (expected ~5GB)")

        return True
    else:
        log_error(f"Model file not found: {model_path}")
        log_info("  Download manually or re-run setup_phase0.sh")
        return False

def check_database():
    """Check SQLite database"""
    db_path = Path("data/registry.db")

    if not db_path.exists():
        log_error(f"Database not found: {db_path}")
        return False

    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()

        # Count tables
        cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
        table_count = cursor.fetchone()[0]

        log_success(f"SQLite database: {db_path} ({table_count} tables)")

        # Check specific tables exist
        expected_tables = [
            'trust_levels', 'category_approvals', 'tools',
            'adapters', 'knowledge_modules', 'policy_audit'
        ]

        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row[0] for row in cursor.fetchall()]

        missing = [t for t in expected_tables if t not in tables]
        if missing:
            log_warning(f"  Missing tables: {', '.join(missing)}")
        else:
            log_success(f"  All core tables present")

        conn.close()
        return True

    except Exception as e:
        log_error(f"Database error: {e}")
        return False

def check_chromadb():
    """Check ChromaDB directory"""
    vector_db_path = Path("data/vector_db")

    if not vector_db_path.exists():
        log_error(f"ChromaDB directory not found: {vector_db_path}")
        return False

    try:
        import chromadb
        client = chromadb.PersistentClient(path=str(vector_db_path))

        # Try to get collections
        collections = client.list_collections()
        log_success(f"ChromaDB: Initialized ({len(collections)} collections)")

        return True
    except Exception as e:
        log_error(f"ChromaDB error: {e}")
        return False

def check_directories():
    """Check required directories exist"""
    required_dirs = [
        "src",
        "data/models",
        "data/adapters",
        "data/vector_db",
        "tools",
        "knowledge",
        "logs",
        "config",
    ]

    all_ok = True
    for dir_path in required_dirs:
        path = Path(dir_path)
        if path.exists():
            log_success(f"Directory: {dir_path}")
        else:
            log_error(f"Directory missing: {dir_path}")
            all_ok = False

    return all_ok

def check_config_files():
    """Check configuration files"""
    config_files = {
        "config/system.yaml": "System configuration",
        "config/policy.yaml": "Policy configuration",
        ".env": "Environment variables",
    }

    all_ok = True
    for file_path, name in config_files.items():
        path = Path(file_path)
        if path.exists():
            log_success(f"{name}: {file_path}")
        else:
            log_warning(f"{name} missing: {file_path}")
            if file_path == ".env":
                log_info("  Run setup_phase0.sh to create .env")
            all_ok = False

    return all_ok

def test_model_loading():
    """Test actually loading the model"""
    model_path = Path("data/models/qwen2.5-vl-7b-instruct-abliterated-q4_k_m.gguf")

    if not model_path.exists():
        log_warning("Model file not found - skipping load test")
        return False

    try:
        from llama_cpp import Llama

        log_info("Testing model load (this may take 30-60 seconds)...")

        llm = Llama(
            model_path=str(model_path),
            n_gpu_layers=-1,  # Try all layers on GPU
            n_ctx=512,  # Small context for testing
            verbose=False
        )

        log_success("Model load test: SUCCESS")
        log_info(f"  Context length: {llm.n_ctx()}")

        # Test generation
        log_info("Testing text generation...")
        response = llm("Say 'OK'", max_tokens=5)
        text = response['choices'][0]['text'].strip()

        log_success(f"Generation test: SUCCESS")
        log_info(f"  Response: {text[:50]}...")

        return True

    except Exception as e:
        log_error(f"Model load failed: {e}")
        log_info("  This may be normal if you don't have 8GB VRAM free")
        return False

def check_docker():
    """Check Docker is running"""
    import subprocess

    try:
        result = subprocess.run(
            ['docker', 'ps'],
            capture_output=True,
            timeout=5
        )

        if result.returncode == 0:
            log_success("Docker: Running")
            return True
        else:
            log_warning("Docker: Not accessible (may need sudo)")
            return False

    except FileNotFoundError:
        log_error("Docker: Not installed")
        return False
    except subprocess.TimeoutExpired:
        log_error("Docker: Timeout")
        return False
    except Exception as e:
        log_error(f"Docker: Error ({e})")
        return False

def main():
    print("=" * 60)
    print("RAGME Installation Verification")
    print("=" * 60)
    print()

    checks = {
        "Python Version": check_python_version,
        "Dependencies": check_dependencies,
        "llama-cpp-python": check_llama_cpp,
        "Directory Structure": check_directories,
        "Configuration Files": check_config_files,
        "Model File": check_model_file,
        "SQLite Database": check_database,
        "ChromaDB": check_chromadb,
        "Docker": check_docker,
    }

    results = {}

    for name, check_func in checks.items():
        print(f"\n[{name}]")
        try:
            results[name] = check_func()
        except Exception as e:
            log_error(f"Check failed with exception: {e}")
            results[name] = False

    # Optional: Model loading test
    print(f"\n[Model Loading Test]")
    log_info("This test will load the model on GPU (optional)")
    try:
        user_input = input("Run model load test? (y/N): ").strip().lower()
        if user_input == 'y':
            results["Model Loading"] = test_model_loading()
        else:
            log_info("Skipped")
            results["Model Loading"] = None
    except KeyboardInterrupt:
        print("\nSkipped")
        results["Model Loading"] = None

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)

    passed = sum(1 for v in results.values() if v is True)
    failed = sum(1 for v in results.values() if v is False)
    skipped = sum(1 for v in results.values() if v is None)
    total = passed + failed

    print(f"\nPassed: {passed}/{total}")
    print(f"Failed: {failed}/{total}")
    if skipped > 0:
        print(f"Skipped: {skipped}")

    if failed == 0:
        print(f"\n{Colors.GREEN}✓ All checks passed! Phase 0 installation complete.{Colors.END}")
        print("\nYou can now proceed to Phase 1: Intelligence Layer")
        return 0
    else:
        print(f"\n{Colors.RED}✗ Some checks failed. Please review errors above.{Colors.END}")
        print("\nTry:")
        print("  • Re-run ./setup_phase0.sh")
        print("  • Check INSTALL.md for manual steps")
        print("  • Verify prerequisites (NVIDIA drivers, disk space)")
        return 1

if __name__ == "__main__":
    sys.exit(main())
