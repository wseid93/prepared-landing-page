# Reusable Components for Listicles and Chef Profiles

This directory contains reusable HTML components that can be included in both listicle articles and chef profile pages for a consistent user experience.

## Available Components

### Navigation Bar (`navigation.html`)
The site-wide navigation bar that should be included at the top of each page.

### Footer (`footer.html`)
The standard footer with copyright information and links.

## How to Use

Since the static site generator doesn't have server-side includes, these components are meant to be copied into new pages when created. When making updates to the navigation or footer, make the changes here first, then update all pages to ensure consistency.

### Recommended Implementation

For a more dynamic approach, you could:

1. Use a static site generator like Jekyll, Hugo, or 11ty that supports partial inclusion
2. Implement a simple build script that processes these includes during deployment
3. Use JavaScript to fetch and inject these components at runtime (though this may impact SEO)

## For Maintainers

When making changes to these components:

1. Update the source files in this directory first
2. Create a list of all pages that use these components
3. Update each page accordingly to maintain consistency

This approach ensures a consistent user experience across all pages while making maintenance more manageable. 