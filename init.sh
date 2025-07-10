#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Initializing PostgreSQL backup system...${NC}"
echo ""

if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please configure the variables in .env before continuing"
    exit 1
fi

source .env

if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$SCHEDULE" ] || [ -z "$BACKUP_KEEP_DAYS" ]; then
    echo -e "${RED}❌ Error: All required variables must be defined in .env${NC}"
    echo ""
    echo "Required variables:"
    echo "  POSTGRES_HOST=${POSTGRES_HOST:-'(empty)'}"
    echo "  POSTGRES_DB=${POSTGRES_DB:-'(empty)'}"
    echo "  POSTGRES_USER=${POSTGRES_USER:-'(empty)'}"
    echo "  POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-'(empty)'}"
    echo "  SCHEDULE=${SCHEDULE:-'(empty)'}"
    echo "  BACKUP_KEEP_DAYS=${BACKUP_KEEP_DAYS:-'(empty)'}"
    exit 1
fi

echo -e "${YELLOW}📡 Creating Docker network...${NC}"
if docker network create backup_network 2>/dev/null; then
    echo -e "${GREEN}✅ Network 'backup_network' created${NC}"
else
    echo -e "${YELLOW}⚠️  Network 'backup_network' already exists${NC}"
fi

echo ""
echo -e "${YELLOW}📦 Pulling Docker images...${NC}"
docker compose pull

echo ""
echo -e "${YELLOW}📂 Creating backup directory...${NC}"
mkdir -p backups
chmod 755 backups

echo ""
echo -e "${YELLOW}🚀 Starting services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}✅ Backup system initialized successfully${NC}"
echo ""
echo "📊 Service status:"
docker compose ps

echo ""
echo "📋 Useful commands:"
echo "  View logs:          docker compose logs -f"
echo "  Manual backup:      docker exec pg_backup /backup.sh"
echo "  View backups:       ls -lah backups/"
echo "  Restore backup:     ./restore_backup.sh backups/file.sql"
