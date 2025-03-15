# Automated Deployment for Prepared Landing Page

This document explains how to use the automated deployment scripts for the Prepared Landing Page website with WebP and AVIF image optimization.

## Quick Start

To deploy your site with a single command:

```bash
./deploy.sh
```

This will:
1. Scan your HTML for Imgur image references
2. Download any missing images
3. Convert all images to WebP and AVIF formats
4. Deploy to a Netlify draft URL for preview

To deploy to production:

```bash
./deploy.sh --production
```

## Prerequisites

The deployment script requires the following tools:

- **cwebp**: For WebP conversion
  - macOS: `brew install webp`
  - Linux: `apt-get install webp`

- **avifenc**: For AVIF conversion
  - macOS: `brew install libavif`
  - Linux: `apt-get install libavif-bin`

- **netlify-cli**: For Netlify deployment
  - `npm install netlify-cli -g`

## Command Line Options

The `deploy.sh` script accepts the following options:

| Option | Description |
|--------|-------------|
| `--skip-image-conversion` | Skip the image conversion step |
| `--skip-deploy` | Skip the Netlify deployment (prepare files only) |
| `--production` | Deploy to the production site (otherwise deploys to a draft URL) |
| `--help` | Show the help message |

## GitHub Actions Integration

This project includes GitHub Actions integration for automatic deployment when you push to the main branch.

### Setup GitHub Actions

1. Add the following secrets to your GitHub repository:
   - `NETLIFY_AUTH_TOKEN`: Your Netlify authentication token
   - `NETLIFY_SITE_ID`: Your Netlify site ID

2. Push your code to the `main` branch

3. GitHub Actions will automatically run the deployment script

### Get Your Netlify Tokens

To get your Netlify tokens:

1. Get your site ID:
   ```bash
   netlify sites:list
   ```

2. Get your auth token:
   ```bash
   netlify auth:tokens
   ```
   Or create a new personal access token in the Netlify UI (User settings → Applications).

## Manual Deployment

If you prefer to deploy manually:

1. Run the script without deployment:
   ```bash
   ./deploy.sh --skip-deploy
   ```

2. The optimized images will be in the `webp/` and `avif/` directories

3. Deploy using the Netlify UI or CLI:
   ```bash
   netlify deploy --prod
   ```

## Adding New Images

When you add new Imgur images to your HTML:

1. The script will automatically detect the new images
2. It will download the originals and convert them
3. It will deploy them with your site

No additional steps required!

## Troubleshooting

- **Missing images**: Ensure your image URLs in HTML are in the format `https://i.imgur.com/IMAGE_ID.ext`
- **Conversion errors**: Make sure cwebp and avifenc are properly installed
- **Deployment errors**: Verify your Netlify authentication is set up correctly

## Need Help?

If you encounter any issues, please check:
- Command installation status
- Netlify authentication
- Image URL format in your HTML 