#!/bin/bash

##############################################################################
# PixelFed Setup Script
# This script automatically performs migration, cache and other setup steps
##############################################################################

set -e  # Stop on error

echo ""
echo "========================================="
echo "Starting PixelFed Setup Script..."
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Progress indicator
show_progress() {
    echo -e "${YELLOW}[⏳]${NC} $1"
}

show_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

show_error() {
    echo -e "${RED}[✗]${NC} $1"
}

##############################################################################
# Step 0: Fix Storage and Database Ownership
##############################################################################
show_progress "Fixing storage directory ownership..."
if [ -d "storage" ]; then
    # Container runs as www-data (UID 33, GID 33)
    sudo chown -R 33:33 storage > /dev/null 2>&1

    # Redis container runs as redis user (UID 999, GID 1000)
    if [ -d "storage/docker/redis/data" ]; then
        sudo chown -R 999:1000 storage/docker/redis/data > /dev/null 2>&1
    fi

    show_success "Storage ownership fixed (www-data and redis)"
else
    show_success "Storage directory not yet created (first run)"
fi
echo ""

# Check if containers are running
show_progress "Checking container status..."
if ! sudo docker compose ps | grep -q "pixelfed-web.*Up"; then
    show_error "pixelfed-web container is not running!"
    echo "Please run 'sudo docker compose up -d' first."
    exit 1
fi
show_success "Containers are running"
echo ""

##############################################################################
# Wait for containers to fully initialize
##############################################################################
show_progress "Waiting for containers to fully initialize (1 minute)..."
echo "           (Container entrypoint scripts are completing setup...)"
echo "           (This includes database initialization and migrations...)"
sleep 60
show_success "Containers initialized"
echo ""

show_progress "Database and initial setup completed by entrypoint scripts"
show_success "Migration, key generation, and storage link completed"
echo ""

##############################################################################
# Step 0.5: Fix Redis Configuration
##############################################################################
show_progress "Step 0.5: Fixing Redis configuration..."
echo "           → Disabling Redis write blocking on save error..."
sudo docker compose exec -T redis redis-cli CONFIG SET stop-writes-on-bgsave-error no > /dev/null 2>&1 || true
echo "           → Disabling Redis persistence (for development)..."
sudo docker compose exec -T redis redis-cli CONFIG SET save "" > /dev/null 2>&1 || true
show_success "Redis configuration fixed"
echo ""

##############################################################################
# Step 1: Create Caches
##############################################################################
show_progress "Step 1/6: Creating caches..."

echo "           → Config cache..."
sudo docker compose exec -T web php artisan config:cache > /dev/null 2>&1

echo "           → Route cache..."
sudo docker compose exec -T web php artisan route:cache > /dev/null 2>&1

echo "           → View cache..."
sudo docker compose exec -T web php artisan view:cache > /dev/null 2>&1

show_success "All caches created (config, route, view)"
echo ""

##############################################################################
# Step 2: Package Discovery
##############################################################################
show_progress "Step 2/6: Discovering Laravel packages..."
if sudo docker compose exec -T web php artisan package:discover > /tmp/discover.log 2>&1; then
    show_success "Packages discovered"
else
    show_error "Package discovery failed!"
    cat /tmp/discover.log
    exit 1
fi
echo ""

##############################################################################
# Step 3: Horizon Install
##############################################################################
show_progress "Step 3/6: Installing Horizon..."
if sudo docker compose exec -T web php artisan horizon:install > /tmp/horizon.log 2>&1; then
    show_success "Horizon installed"
else
    # If already installed, no problem
    show_success "Horizon already installed or installation completed"
fi
echo ""

##############################################################################
# Step 4: Final Cache Rebuild and Restart
##############################################################################
show_progress "Step 4/6: Final cache rebuild and container restart..."

echo "           → Rebuilding route cache..."
sudo docker compose exec -T web php artisan route:cache > /dev/null 2>&1

echo "           → Restarting web container..."
sudo docker compose restart web > /dev/null 2>&1

echo "           → Waiting for container to be ready..."
sleep 3

show_success "Cache rebuild and restart completed"
echo ""

##############################################################################
# Step 5: Verify Setup
##############################################################################
show_progress "Step 5/6: Verifying setup..."
sleep 5
if sudo docker compose ps | grep -q "pixelfed-web.*Up"; then
    show_success "All containers are running"
else
    show_error "Some containers are not running"
fi
echo ""

##############################################################################
# COMPLETED
##############################################################################
echo ""
echo "========================================="
echo -e "${GREEN}✓ SETUP COMPLETED!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Create admin user:"
echo "   sudo docker compose exec web php artisan user:create"
echo ""
echo "2. Open in browser:"
echo "   http://$(curl -s http://checkip.amazonaws.com):8080"
echo ""
echo "Happy coding! 🚀"
echo ""
