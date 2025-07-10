#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_help() {
    echo "Usage: $0 <backup_file.sql>"
    echo ""
    echo "Examples:"
    echo "  $0 backups/my_db_2025-07-02_02-00-01.sql"
    echo "  $0 backups/my_db_latest.sql"
    echo ""
    echo "This script will restore the specified backup to the PostgreSQL database"
    echo "configured in the .env file"
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

BACKUP_FILE=$1

if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

source .env

if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    echo -e "${RED}Error: POSTGRES_HOST, POSTGRES_DB, POSTGRES_USER and POSTGRES_PASSWORD variables must be defined in .env${NC}"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
    echo ""
    echo "Available backup files:"
    find backups/ -name "*.sql" -type f 2>/dev/null | head -10 || echo "No backup files available"
    exit 1
fi

echo -e "${YELLOW}Starting backup restoration...${NC}"
echo "File: $BACKUP_FILE"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"
echo ""

read -p "Are you sure you want to restore this backup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

if ! docker ps | grep -q pg_backup; then
    echo -e "${YELLOW}Backup container is not running. Starting...${NC}"
    docker-compose up -d pg_backup
    echo "Waiting for service to be ready..."
    sleep 10
fi

echo -e "${YELLOW}Restoring backup...${NC}"

if PGPASSWORD="$POSTGRES_PASSWORD" docker exec -i pg_backup psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$BACKUP_FILE"; then
    echo -e "${GREEN}✅ Backup restored successfully${NC}"
else
    echo -e "${RED}❌ Error during restoration${NC}"
    echo ""
    echo "You can try to restore manually with:"
    echo "PGPASSWORD=\"\$POSTGRES_PASSWORD\" docker exec -i pg_backup psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB < $BACKUP_FILE"
    exit 1
fi

echo ""
echo -e "${GREEN}Restoration completed${NC}"
