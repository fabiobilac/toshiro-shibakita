#!/bin/bash

# Script para inicializar Docker Swarm
# Projeto Toshiro Shibakita - Microsserviços com Docker

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Docker Swarm - Projeto Toshiro Shibakita             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado"
    exit 1
fi

# Verificar se já está em modo Swarm
if docker info 2>/dev/null | grep -q "Swarm: active"; then
    print_warning "Docker Swarm já está ativo"
    
    read -p "Deseja reiniciar o Swarm? (s/n): " restart
    if [ "$restart" = "s" ]; then
        print_info "Deixando o Swarm..."
        docker swarm leave --force
    else
        print_info "Mantendo configuração atual"
        exit 0
    fi
fi

# Inicializar Swarm
print_info "Inicializando Docker Swarm..."
MANAGER_IP=$(hostname -I | awk '{print $1}')
docker swarm init --advertise-addr $MANAGER_IP

print_success "Docker Swarm inicializado!"
echo ""

# Obter token para workers
WORKER_TOKEN=$(docker swarm join-token worker -q)
print_info "Token para adicionar workers:"
echo -e "${YELLOW}docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377${NC}"
echo ""

# Criar networks
print_info "Criando networks overlay..."
docker network create --driver overlay --attachable frontend || true
docker network create --driver overlay --attachable backend || true

print_success "Networks criadas!"
echo ""

# Construir imagens
print_info "Construindo imagens Docker..."
cd "$(dirname "$0")/.."

docker build -t toshiro-nginx:latest ./nginx
docker build -t toshiro-php:latest ./php-app
docker build -t toshiro-mysql:latest ./mysql

print_success "Imagens construídas!"
echo ""

# Deploy da stack
print_info "Fazendo deploy da stack..."
docker stack deploy -c docker-compose.swarm.yml toshiro

print_success "Stack deployada!"
echo ""

# Aguardar serviços
print_info "Aguardando serviços iniciarem..."
sleep 10

# Verificar status
print_info "Status dos serviços:"
docker stack services toshiro

echo ""
print_info "Status dos containers:"
docker stack ps toshiro

echo ""
print_success "Deploy concluído!"
echo ""
print_info "Comandos úteis:"
echo "  - Ver serviços: docker stack services toshiro"
echo "  - Ver logs: docker service logs toshiro_php-app"
echo "  - Escalar serviço: docker service scale toshiro_php-app=5"
echo "  - Remover stack: docker stack rm toshiro"
echo ""
