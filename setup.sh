#!/bin/bash

# UNO Game - Quick Start Setup Script
# This script sets up the development environment for UNO Game

set -e

echo "=================================="
echo "UNO Game - Development Setup"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed. Please install Node.js 16+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $(node -v) installed${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm is not installed. Please install npm 8+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ npm $(npm -v) installed${NC}"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed. Please install Flutter 3.0+${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi
echo -e "${GREEN}✓ Flutter $(flutter --version | head -1) installed${NC}"

# Check Docker (optional)
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker installed (optional)${NC}"
else
    echo -e "${YELLOW}⚠ Docker not found (optional for containerization)${NC}"
fi

echo ""

# Setup Backend
echo -e "${YELLOW}Setting up Backend...${NC}"

if [ -d "backend" ]; then
    cd backend
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "Installing backend dependencies..."
        npm install
    else
        echo -e "${GREEN}✓ Backend dependencies already installed${NC}"
    fi
    
    # Create .env if it doesn't exist
    if [ ! -f ".env" ]; then
        echo "Creating .env file..."
        cp .env.example .env
        echo -e "${YELLOW}⚠ Please edit .env with your Firebase credentials${NC}"
    else
        echo -e "${GREEN}✓ .env file exists${NC}"
    fi
    
    cd ..
else
    echo -e "${RED}Backend directory not found${NC}"
    exit 1
fi

echo ""

# Setup Flutter App
echo -e "${YELLOW}Setting up Flutter Application...${NC}"

if [ -d "flutter_app" ]; then
    cd flutter_app
    
    echo "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code
    if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
        echo "Building generated code..."
        flutter pub run build_runner build --delete-conflicting-outputs
    fi
    
    cd ..
else
    echo -e "${RED}Flutter app directory not found${NC}"
    exit 1
fi

echo ""

# Docker setup (optional)
echo -e "${YELLOW}Docker Setup (Optional)${NC}"

if command -v docker &> /dev/null; then
    read -p "Do you want to build Docker images? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Building Docker images..."
        docker-compose build
        echo -e "${GREEN}✓ Docker images built${NC}"
        echo ""
        echo "To start services with Docker:"
        echo "  docker-compose up"
    fi
else
    echo "Skipping Docker setup (not installed)"
fi

echo ""

# Summary
echo -e "${GREEN}=================================="
echo "Setup Complete!"
echo "==================================${NC}"
echo ""
echo "Next steps:"
echo "1. Edit backend/.env with Firebase credentials"
echo "2. Configure flutter_app/lib/utils/constants.dart with API endpoint"
echo "3. Start the backend:"
echo "   cd backend && npm run dev"
echo "4. In another terminal, start Flutter app:"
echo "   cd flutter_app && flutter run"
echo ""
echo "For detailed setup instructions, see:"
echo "  - README.md - Project overview and quick start"
echo "  - documentation/DEPLOYMENT_GUIDE.md - Production deployment"
echo "  - documentation/API_DOCUMENTATION.md - API endpoints"
echo "  - documentation/DATABASE_SCHEMA.md - Firestore structure"
echo "  - documentation/GAME_RULES.md - Complete game rules"
echo ""
echo -e "${YELLOW}Documentation available in ./documentation/ directory${NC}"
echo ""
