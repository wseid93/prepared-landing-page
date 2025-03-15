#!/bin/bash

# ======================================================
# Prepared Landing Page - Automated Deployment Script
# ======================================================
#
# This script:
# 1. Converts images to WebP and AVIF formats
# 2. Optimizes HTML/CSS/JS
# 3. Deploys everything to Netlify
#
# Prerequisites:
# - cwebp (for WebP conversion)
# - avifenc (for AVIF conversion)
# - Netlify CLI (npm install netlify-cli --save-dev)

set -e  # Exit on error

# Color formatting
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SITE_NAME="eatprepared"
IMAGE_QUALITY_WEBP=80
IMAGE_QUALITY_AVIF=65
ORIGINAL_IMAGE_DIR="original"
DEPLOY_DIR="."
WEBP_DIR="webp"
AVIF_DIR="avif"
IMGUR_DOMAINS=("i.imgur.com")
SKIP_IMAGE_CONVERSION=false
SKIP_DEPLOY=false
PRODUCTION_DEPLOY=false

# Banner
echo -e "${BLUE}"
echo "======================================================="
echo "  PREPARED LANDING PAGE - AUTOMATED DEPLOYMENT SCRIPT  "
echo "======================================================="
echo -e "${NC}"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-image-conversion) SKIP_IMAGE_CONVERSION=true ;;
        --skip-deploy) SKIP_DEPLOY=true ;;
        --production) PRODUCTION_DEPLOY=true ;;
        --help) 
            echo "Usage: ./deploy.sh [options]"
            echo ""
            echo "Options:"
            echo "  --skip-image-conversion  Skip image conversion step"
            echo "  --skip-deploy            Skip Netlify deployment"
            echo "  --production             Deploy to production (otherwise deploys to draft URL)"
            echo "  --help                   Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check for required commands
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed.${NC}"
        case "$1" in
            cwebp)
                echo "Install with: brew install webp (macOS) or apt-get install webp (Linux)"
                ;;
            avifenc)
                echo "Install with: brew install libavif (macOS) or apt-get install libavif-bin (Linux)"
                ;;
            npx)
                echo "Install with: npm install -g npx"
                ;;
        esac
        exit 1
    fi
}

if [ "$SKIP_IMAGE_CONVERSION" = false ]; then
    check_command cwebp
    check_command avifenc
fi

if [ "$SKIP_DEPLOY" = false ]; then
    check_command npx
fi

# Make sure directories exist
mkdir -p "$WEBP_DIR" "$AVIF_DIR" "$ORIGINAL_IMAGE_DIR"

# Function to extract image IDs from HTML
extract_image_ids() {
    echo -e "${BLUE}Scanning HTML for image IDs...${NC}"
    
    # This will extract the image IDs from imgur URLs in the HTML file
    EXTRACTED_IDS=$(grep -o 'imgur\.com/[a-zA-Z0-9]\+\.' index.html | sed 's/imgur\.com\///g' | sed 's/\.//g' | sort | uniq)
    
    if [ -z "$EXTRACTED_IDS" ]; then
        echo -e "${YELLOW}No Imgur image IDs found in HTML.${NC}"
        return
    fi
    
    echo -e "${GREEN}Found $(echo "$EXTRACTED_IDS" | wc -l | tr -d ' ') unique image IDs.${NC}"
    
    # Save to a file
    echo "$EXTRACTED_IDS" > image_ids.txt
    echo -e "${GREEN}Saved image IDs to image_ids.txt${NC}"
}

# Function to download images if needed
download_images() {
    if [ ! -f image_ids.txt ]; then
        echo -e "${YELLOW}No image_ids.txt found. Scanning HTML...${NC}"
        extract_image_ids
    fi
    
    if [ ! -f image_ids.txt ]; then
        echo -e "${RED}No image IDs found to download.${NC}"
        return
    fi
    
    echo -e "${BLUE}Downloading missing images...${NC}"
    
    while IFS= read -r id; do
        for ext in jpg jpeg png; do
            if [ ! -f "$ORIGINAL_IMAGE_DIR/$id.$ext" ]; then
                echo -e "${YELLOW}Downloading $id.$ext...${NC}"
                curl -s "https://i.imgur.com/$id.$ext" -o "$ORIGINAL_IMAGE_DIR/$id.$ext"
                
                # Check if file was downloaded successfully (non-zero size)
                if [ -s "$ORIGINAL_IMAGE_DIR/$id.$ext" ]; then
                    echo -e "${GREEN}Downloaded $id.$ext${NC}"
                    break
                else
                    rm "$ORIGINAL_IMAGE_DIR/$id.$ext"
                fi
            else
                echo -e "${GREEN}$id.$ext already exists${NC}"
                break
            fi
        done
    done < image_ids.txt
    
    echo -e "${GREEN}Image download complete!${NC}"
}

# Function to convert images
convert_images() {
    echo -e "${BLUE}Starting image conversion...${NC}"
    
    find "$ORIGINAL_IMAGE_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | while read -r img; do
        filename=$(basename "$img")
        id="${filename%.*}"
        
        # Convert to WebP
        if [ ! -f "$WEBP_DIR/$id.webp" ]; then
            echo -e "${YELLOW}Converting $filename to WebP...${NC}"
            cwebp -q "$IMAGE_QUALITY_WEBP" "$img" -o "$WEBP_DIR/$id.webp"
            echo -e "${GREEN}Created $id.webp${NC}"
        else
            echo -e "${GREEN}$id.webp already exists${NC}"
        fi
        
        # Convert to AVIF
        if [ ! -f "$AVIF_DIR/$id.avif" ]; then
            echo -e "${YELLOW}Converting $filename to AVIF...${NC}"
            avifenc --min 0 --max 63 -a end-usage=q -a cq-level=18 "$img" "$AVIF_DIR/$id.avif"
            echo -e "${GREEN}Created $id.avif${NC}"
        else
            echo -e "${GREEN}$id.avif already exists${NC}"
        fi
    done
    
    echo -e "${GREEN}Image conversion complete!${NC}"
}

# Function to deploy to Netlify
deploy_to_netlify() {
    echo -e "${BLUE}Preparing Netlify deployment...${NC}"
    
    # Check if user is logged in to Netlify
    if ! npx netlify status &>/dev/null; then
        echo -e "${YELLOW}You are not logged in to Netlify. Logging in...${NC}"
        npx netlify login
    fi
    
    # Check if site exists and is linked
    if ! npx netlify status | grep -q "Netlify Site Name"; then
        echo -e "${YELLOW}Site not linked. Initializing...${NC}"
        
        # Check if site exists or needs to be created
        if npx netlify sites:list | grep -q "$SITE_NAME"; then
            echo -e "${YELLOW}Linking to existing site: $SITE_NAME${NC}"
            npx netlify link --name "$SITE_NAME"
        else
            echo -e "${YELLOW}Creating new site: $SITE_NAME${NC}"
            npx netlify sites:create --name "$SITE_NAME"
            npx netlify link --name "$SITE_NAME"
        fi
    fi
    
    # Deploy to Netlify
    if [ "$PRODUCTION_DEPLOY" = true ]; then
        echo -e "${BLUE}Deploying to PRODUCTION...${NC}"
        npx netlify deploy --prod --dir="$DEPLOY_DIR"
    else
        echo -e "${BLUE}Deploying to draft URL...${NC}"
        npx netlify deploy --dir="$DEPLOY_DIR"
    fi
    
    echo -e "${GREEN}Deployment complete!${NC}"
}

# Main execution
main() {
    # Extract image IDs from HTML
    extract_image_ids
    
    if [ "$SKIP_IMAGE_CONVERSION" = false ]; then
        # Download images if needed
        download_images
        
        # Convert images to WebP and AVIF
        convert_images
    else
        echo -e "${YELLOW}Skipping image conversion as requested.${NC}"
    fi
    
    # Print summary of files
    echo -e "${BLUE}File summary:${NC}"
    ls -la "$WEBP_DIR" | wc -l | xargs echo "WebP files:"
    ls -la "$AVIF_DIR" | wc -l | xargs echo "AVIF files:"
    
    if [ "$SKIP_DEPLOY" = false ]; then
        # Deploy to Netlify
        deploy_to_netlify
    else
        echo -e "${YELLOW}Skipping deployment as requested.${NC}"
        echo -e "${GREEN}All files are ready for manual deployment:${NC}"
        echo "  1. WebP images: $WEBP_DIR/"
        echo "  2. AVIF images: $AVIF_DIR/"
        echo "  3. HTML/CSS: $DEPLOY_DIR/"
    fi
    
    echo -e "${GREEN}All done! 🎉${NC}"
}

# Run the main function
main 