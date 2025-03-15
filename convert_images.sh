#!/bin/bash

# Image Conversion Script for Prepared Landing Page
# This script downloads images from Imgur and converts them to WebP and AVIF formats

mkdir -p converted_images/{webp,avif}

# Array of image IDs to process
IMAGES=(
  "dD2wjpo"   # Browse and select a local chef
  "5qtjtPC"   # Select a personalized meal plan
  "myhrFjr"   # Complete checkout and track
  "lhhxgxB"   # Hero background image
  "q46wE7H"   # Chef Jonathan
  "zwtXFoR"   # Chef Alexander
  "Uno4TR4"   # Chef Moises
  "52OMvzu"   # Lean Mean Meal Prep
  "OwiW1oY"   # Fresh Off The Boat
  "07wOkmX"   # 80/20 Fitness
  "dk8y4Hp"   # OC FIT
)

echo "Starting image conversion process..."

for img in "${IMAGES[@]}"
do
  echo "Processing $img..."
  
  # Download original image if it doesn't exist
  if [ ! -f "original/$img.png" ]; then
    echo "Downloading $img..."
    curl -s "https://i.imgur.com/$img.png" -o "original/$img.png"
  fi
  
  # Convert to WebP using one of these methods:
  
  # Option 1: Using cwebp (if installed)
  if command -v cwebp &> /dev/null; then
    echo "Converting to WebP using cwebp..."
    cwebp -q 80 "original/$img.png" -o "converted_images/webp/$img.webp"
  
  # Option 2: Using ImageMagick (if installed)
  elif command -v convert &> /dev/null; then
    echo "Converting to WebP using ImageMagick..."
    convert "original/$img.png" -quality 80 "converted_images/webp/$img.webp"
  
  # Option 3: Using Squoosh CLI (if installed)
  elif command -v squoosh-cli &> /dev/null; then
    echo "Converting to WebP using Squoosh..."
    squoosh-cli --webp '{quality:80}' "original/$img.png" -d "converted_images/webp"
  
  else
    echo "No WebP conversion tools found. Please install one of: cwebp, ImageMagick, or squoosh-cli"
  fi
  
  # Convert to AVIF using one of these methods:
  
  # Option 1: Using ImageMagick (if installed and supports AVIF)
  if command -v convert &> /dev/null && convert -list format | grep -q AVIF; then
    echo "Converting to AVIF using ImageMagick..."
    convert "original/$img.png" -quality 65 "converted_images/avif/$img.avif"
  
  # Option 2: Using Squoosh CLI (if installed)
  elif command -v squoosh-cli &> /dev/null; then
    echo "Converting to AVIF using Squoosh..."
    squoosh-cli --avif '{quality:65}' "original/$img.png" -d "converted_images/avif"
  
  # Option 3: Using avifenc (if installed)
  elif command -v avifenc &> /dev/null; then
    echo "Converting to AVIF using avifenc..."
    avifenc --min 0 --max 63 -a end-usage=q -a cq-level=18 "original/$img.png" "converted_images/avif/$img.avif" 
  
  else
    echo "No AVIF conversion tools found. Please install one of: ImageMagick with AVIF support, squoosh-cli, or avifenc"
  fi
  
  echo "Done processing $img"
done

echo "Conversion complete! Files are in the converted_images directory."
echo "Remember to upload these to your server or use a CDN like Cloudinary." 