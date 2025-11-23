#!/bin/bash

# Script de Deploy para AWS
# Projeto Toshiro Shibakita - Microsserviços com Docker

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funções
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

# Verificar se AWS CLI está instalado
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI não está instalado. Instale com: sudo apt-get install awscli"
        exit 1
    fi
    print_success "AWS CLI encontrado"
}

# Verificar se Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker não está instalado"
        exit 1
    fi
    print_success "Docker encontrado"
}

# Verificar se Docker Compose está instalado
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose não está instalado"
        exit 1
    fi
    print_success "Docker Compose encontrado"
}

# Criar instância EC2
create_ec2_instance() {
    print_info "Criando instância EC2..."
    
    # Configurações (ajuste conforme necessário)
    AMI_ID="ami-0c55b159cbfafe1f0"  # Amazon Linux 2 (ajuste para sua região)
    INSTANCE_TYPE="t2.medium"
    KEY_NAME="your-key-pair"
    SECURITY_GROUP="your-security-group"
    
    print_warning "Configure as variáveis AMI_ID, KEY_NAME e SECURITY_GROUP antes de executar"
    
    # Comando para criar instância (descomente e ajuste)
    # aws ec2 run-instances \
    #     --image-id $AMI_ID \
    #     --instance-type $INSTANCE_TYPE \
    #     --key-name $KEY_NAME \
    #     --security-group-ids $SECURITY_GROUP \
    #     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=toshiro-shibakita}]'
}

# Instalar Docker na instância EC2
install_docker_ec2() {
    print_info "Instalando Docker na instância EC2..."
    
    cat << 'EOF' > /tmp/install-docker.sh
#!/bin/bash
# Atualizar sistema
sudo yum update -y

# Instalar Docker
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker --version
docker-compose --version
EOF
    
    print_success "Script de instalação criado em /tmp/install-docker.sh"
    print_info "Execute este script na instância EC2 após conectar via SSH"
}

# Deploy da aplicação
deploy_application() {
    print_info "Fazendo deploy da aplicação..."
    
    # Construir imagens
    print_info "Construindo imagens Docker..."
    docker-compose build
    
    # Subir serviços
    print_info "Iniciando serviços..."
    docker-compose up -d
    
    # Verificar status
    print_info "Verificando status dos containers..."
    docker-compose ps
    
    print_success "Deploy concluído!"
}

# Configurar Security Group
configure_security_group() {
    print_info "Configurações necessárias para o Security Group:"
    echo ""
    echo "Portas que devem estar abertas:"
    echo "  - 22 (SSH) - Para acesso remoto"
    echo "  - 80 (HTTP) - Para acesso à aplicação"
    echo "  - 8080 (HTTP) - Porta alternativa da aplicação"
    echo "  - 8081 (HTTP) - PHPMyAdmin"
    echo "  - 3306 (MySQL) - Apenas se precisar acesso externo ao banco"
    echo ""
}

# Menu principal
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Projeto Toshiro Shibakita - Deploy AWS                ║${NC}"
    echo -e "${BLUE}║     Microsserviços com Docker                             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "Verificando pré-requisitos..."
    check_docker
    check_docker_compose
    
    echo ""
    echo "Escolha uma opção:"
    echo "1) Verificar AWS CLI"
    echo "2) Gerar script de instalação Docker para EC2"
    echo "3) Configurações do Security Group"
    echo "4) Deploy local (teste)"
    echo "5) Sair"
    echo ""
    
    read -p "Opção: " option
    
    case $option in
        1)
            check_aws_cli
            ;;
        2)
            install_docker_ec2
            ;;
        3)
            configure_security_group
            ;;
        4)
            deploy_application
            ;;
        5)
            print_info "Saindo..."
            exit 0
            ;;
        *)
            print_error "Opção inválida"
            exit 1
            ;;
    esac
}

# Executar
main
