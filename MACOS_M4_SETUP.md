# macOS Apple Silicon (M1/M2/M3/M4) Setup Guide

This guide helps you run OpenML services locally on Apple Silicon Macs.

## ⚠️ Known Limitation

The OpenML docker-compose setup uses an older version of Elasticsearch that was built for Intel (x86_64) processors. However, Docker Desktop for Mac includes **Rosetta 2** emulation, which allows Intel containers to run on Apple Silicon.

## ✅ Prerequisites

1. **Docker Desktop for Mac** (with Rosetta 2 enabled)

    - Download: https://www.docker.com/products/docker-desktop
    - During installation, ensure "Use Rosetta for x86/amd64 emulation" is enabled
    - You can verify in Docker Desktop → Settings → General → "Use Rosetta for x86/amd64 emulation on Apple Silicon"

2. **Sufficient Resources**
    - Recommended: 8GB RAM allocated to Docker
    - Recommended: 4 CPUs allocated to Docker
    - Configure in Docker Desktop → Settings → Resources

## 🚀 Quick Start (Testing Only)

If you just want to **test OpenML** without modifying code:

```bash
# Set permissions (first time only)
chmod -R 777 data/php

# Start all services
docker compose --profile all up -d

# Check status
docker ps

# View logs
docker logs openml-php-rest-api -f
```

Access services at:

-   **Frontend**: http://localhost:8000
-   **REST API**: http://localhost:8080
-   **ElasticSearch**: http://localhost:9200
-   **MinIO Console**: http://localhost:9001

## 💻 Development Setup

If you want to **develop and modify** OpenML code:

### 1. Clone Required Repositories

```bash
cd ~/Documents/Dev  # or your preferred location

# PHP Backend
git clone https://github.com/openml/OpenML.git

# Frontend
git clone https://github.com/openml/openml.org.git

# Optional: MinIO Data (for parquet conversion)
git clone https://github.com/openml-labs/minio-data.git

# Optional: Croissant Converter
git clone https://github.com/openml/openml-croissant.git
```

### 2. Configure Local Development

Create a `.env` file in the `services` directory:

```bash
# PHP REST API Development
PHP_CODE_DIR=/Users/YOUR_USERNAME/Documents/Dev/OpenML
PHP_CODE_VAR_WWW_OPENML=/var/www/openml

# Frontend Development
FRONTEND_CODE_DIR=/Users/YOUR_USERNAME/Documents/Dev/openml.org
FRONTEND_APP=/app

# Optional: Parquet Converter
# ARFF_TO_PQ_CODE_DIR=/Users/YOUR_USERNAME/Documents/Dev/minio-data
# ARFF_TO_PQ_APP=/app

# Optional: Croissant Converter
# CROISSANT_CODE_DIR=/Users/YOUR_USERNAME/Documents/Dev/openml-croissant/python
# CROISSANT_APP=/app
```

**Replace `YOUR_USERNAME` with your actual username!**

### 3. PHP Backend Configuration

For PHP development, you need to create a configuration file:

```bash
cd /Users/YOUR_USERNAME/Documents/Dev/OpenML
mkdir -p openml_OS/config
cp /Users/YOUR_USERNAME/Documents/Dev/docker-tu/services/config/php/.env openml_OS/config/BASE_CONFIG.php
```

Edit `openml_OS/config/BASE_CONFIG.php` with the correct database and Elasticsearch settings from `config/php/.env`.

### 4. Start Services

```bash
cd /Users/YOUR_USERNAME/Documents/Dev/docker-tu/services

# Set permissions (first time only)
chmod -R 777 data/php

# Start with your local code mounted
docker compose --profile all up -d
```

Now any changes to your local code will be reflected in the containers!

## 🐛 Troubleshooting

### Elasticsearch fails to start

**Symptom**: `openml-elasticsearch` container exits immediately

**Solution**:

1. Check Docker Desktop has Rosetta 2 enabled
2. Increase Docker memory to at least 4GB
3. Check logs: `docker logs openml-elasticsearch`

### Containers are slow

**Symptom**: Services take a long time to respond

**Explanation**: This is expected on Apple Silicon due to Rosetta 2 emulation translating Intel instructions. Elasticsearch in particular may be ~30-50% slower than on Intel Macs.

**Workarounds**:

-   Allocate more CPU/RAM to Docker Desktop
-   Use profile-specific startup (e.g., `--profile frontend` instead of `--profile all`)
-   Consider using a remote development server for intensive work

### Port already in use

**Symptom**: Error like "port 3306 is already allocated"

**Solution**:

```bash
# Check what's using the port
lsof -i :3306

# Stop conflicting services (e.g., local MySQL)
brew services stop mysql

# Or change the port in docker-compose.yaml
```

### PHP container can't write files

**Symptom**: Upload errors or permission denied

**Solution**:

```bash
# On macOS, www-data user doesn't exist, so use chmod
chmod -R 777 data/php
```

### Frontend hot-reload not working

**Symptom**: Code changes don't appear without restarting

**Solution**:

```bash
# Restart the frontend container
docker compose restart frontend-nextjs

# Or use development mode explicitly
cd /Users/YOUR_USERNAME/Documents/Dev/openml.org/app
npm run dev
```

## 📊 Performance Tips

1. **Use selective profiles** instead of `--profile all`:

    ```bash
    docker compose --profile frontend up -d  # Just frontend + dependencies
    docker compose --profile rest-api up -d  # Just API + dependencies
    ```

2. **Exclude services you don't need**:

    - Comment out services in `docker-compose.yaml`
    - Or stop specific containers: `docker stop openml-minio`

3. **Monitor resources**:
    ```bash
    docker stats  # Real-time resource usage
    ```

## 🧹 Cleanup

Stop and remove all containers:

```bash
docker compose --profile all down

# Remove volumes too (⚠️ deletes all data)
docker compose --profile all down -v
```

## 📝 Testing Your Changes

Before submitting a PR:

1. **Test with fresh containers**:

    ```bash
    docker compose down
    docker compose --profile all up -d
    ```

2. **Check logs for errors**:

    ```bash
    docker logs openml-php-rest-api
    docker logs openml-frontend-nextjs
    docker logs openml-elasticsearch
    ```

3. **Verify all services are healthy**:
    ```bash
    docker ps
    # All containers should show "healthy" or "running"
    ```

## 🆘 Getting Help

-   **GitHub Issues**: https://github.com/openml/services/issues
-   **Slack**: Join the OpenML workspace
-   **Documentation**: Check the main [README.md](README.md)

## 📚 Additional Resources

-   [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
-   [Rosetta 2 Emulation](https://docs.docker.com/desktop/settings/mac/#use-rosetta-for-x86amd64-emulation-on-apple-silicon)
-   [OpenML Documentation](https://openml.github.io/OpenML/)

---

**Note**: This guide is community-contributed and tested on macOS Sonoma with M4 chip. Your experience may vary with different macOS versions or chip generations (M1/M2/M3).
