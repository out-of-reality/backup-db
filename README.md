# PostgreSQL Backup System

Sistema automatizado de backups para PostgreSQL usando Docker.

## Instalación

1. Editar `.env`:
```bash
POSTGRES_HOST=tu_host
POSTGRES_DB=tu_nombre_de_base_de_datos
POSTGRES_USER=tu_usuario
POSTGRES_PASSWORD=tu_contraseña_segura
POSTGRES_PORT=5432
SCHEDULE=0 5 * * *
BACKUP_KEEP_DAYS=7
```

2. Ejecutar script de inicialización:
```bash
./init.sh
```

El script automáticamente:
- Crea la red Docker
- Descarga las imágenes
- Crea el directorio de backups
- Levanta todos los servicios

## Restaurar backup

```bash
./restore_backup.sh backups/archivo_backup.sql
```

## Comandos útiles

```bash
# Ver logs
docker-compose logs -f

# Backup manual
docker exec pg_backup /backup.sh

# Ver backups
ls -lah backups/

# Restaurar backup
./restore_backup.sh backups/file.sql

# Estado de servicios
docker-compose ps

# Detener servicios
docker-compose down
```
