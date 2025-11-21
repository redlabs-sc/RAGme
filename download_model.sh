#!/bin/bash

################################################################################
# Alternative Model Download Script
# For: Qwen2.5-VL-7B-Instruct-abliterated (Q4_K_M GGUF)
# Use this if setup_phase0.sh model download fails
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Model details
REPO="mradermacher/Qwen2.5-VL-7B-Instruct-abliterated-GGUF"
FILE="Qwen2.5-VL-7B-Instruct-abliterated.Q4_K_M.gguf"
URL="https://huggingface.co/$REPO/resolve/main/$FILE"
SIZE_GB="4.7"

# Destination
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIR="$PROJECT_DIR/data/models"
DEST_FILE="$MODEL_DIR/qwen2.5-vl-7b-instruct-abliterated-q4_k_m.gguf"

mkdir -p "$MODEL_DIR"

echo "=============================================="
echo "  RAGME Model Download"
echo "=============================================="
echo ""
log_info "Repository: $REPO"
log_info "File: $FILE"
log_info "Size: ~${SIZE_GB}GB"
log_info "Destination: $DEST_FILE"
echo ""

# Check if already exists
if [ -f "$DEST_FILE" ]; then
    EXISTING_SIZE=$(du -h "$DEST_FILE" | cut -f1)
    log_warning "Model file already exists: $DEST_FILE ($EXISTING_SIZE)"
    read -p "Re-download? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Download cancelled"
        exit 0
    fi
    rm "$DEST_FILE"
fi

# Method selection
echo "Choose download method:"
echo "  1) wget (recommended, shows progress)"
echo "  2) curl (alternative)"
echo "  3) huggingface-cli (official, requires login for some repos)"
echo ""
read -p "Select method [1-3] (default: 1): " METHOD
METHOD=${METHOD:-1}

case $METHOD in
    1)
        log_info "Using wget..."
        if ! command -v wget &> /dev/null; then
            log_error "wget not found. Install with: sudo apt install wget"
            exit 1
        fi

        log_info "Starting download (this will take 30min - 2 hours)..."
        wget \
            --continue \
            --progress=bar:force \
            --show-progress \
            -O "$MODEL_DIR/$FILE" \
            "$URL"

        # Rename to standard name
        if [ -f "$MODEL_DIR/$FILE" ]; then
            mv "$MODEL_DIR/$FILE" "$DEST_FILE"
            log_success "Download complete!"
        else
            log_error "Download failed"
            exit 1
        fi
        ;;

    2)
        log_info "Using curl..."
        if ! command -v curl &> /dev/null; then
            log_error "curl not found. Install with: sudo apt install curl"
            exit 1
        fi

        log_info "Starting download (this will take 30min - 2 hours)..."
        curl \
            -L \
            --progress-bar \
            -o "$MODEL_DIR/$FILE" \
            "$URL"

        # Rename to standard name
        if [ -f "$MODEL_DIR/$FILE" ]; then
            mv "$MODEL_DIR/$FILE" "$DEST_FILE"
            log_success "Download complete!"
        else
            log_error "Download failed"
            exit 1
        fi
        ;;

    3)
        log_info "Using huggingface-cli..."

        # Check if huggingface-cli is installed
        if ! command -v huggingface-cli &> /dev/null && ! command -v hf &> /dev/null; then
            log_info "Installing huggingface-hub..."
            pip3 install -q huggingface-hub[cli]
        fi

        # Use newer 'hf' or fallback to 'huggingface-cli'
        if command -v hf &> /dev/null; then
            HF_CMD="hf download"
        else
            HF_CMD="huggingface-cli download"
        fi

        log_info "Starting download..."
        $HF_CMD \
            "$REPO" \
            "$FILE" \
            --local-dir "$MODEL_DIR" \
            --local-dir-use-symlinks False

        # Rename to standard name
        if [ -f "$MODEL_DIR/$FILE" ]; then
            mv "$MODEL_DIR/$FILE" "$DEST_FILE"
            log_success "Download complete!"
        else
            log_error "Download failed"
            exit 1
        fi
        ;;

    *)
        log_error "Invalid selection"
        exit 1
        ;;
esac

# Verify file size
if [ -f "$DEST_FILE" ]; then
    ACTUAL_SIZE=$(du -h "$DEST_FILE" | cut -f1)
    ACTUAL_SIZE_BYTES=$(stat -c%s "$DEST_FILE")
    EXPECTED_SIZE_BYTES=$((47 * 100 * 1024 * 1024))  # ~4.7GB in bytes

    log_info "Downloaded file: $DEST_FILE"
    log_info "File size: $ACTUAL_SIZE"

    if [ "$ACTUAL_SIZE_BYTES" -lt "$EXPECTED_SIZE_BYTES" ]; then
        log_warning "File size seems small (expected ~${SIZE_GB}GB)"
        log_warning "Download may be incomplete. Consider re-downloading."
    else
        log_success "File size looks correct!"
    fi
else
    log_error "File not found after download"
    exit 1
fi

echo ""
log_success "=============================================="
log_success "  Model Download Complete!"
log_success "=============================================="
echo ""
log_info "Next steps:"
echo "  1. Verify: ls -lh $DEST_FILE"
echo "  2. Continue Phase 0 setup: ./setup_phase0.sh"
echo ""
