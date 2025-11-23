.PHONY: help build up down restart logs clean status test

# Cores para output
BLUE=\033[0;34m
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)Projeto Toshiro Shibakita - Microsserviços com Docker$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}'

build: ## Constrói todas as imagens Docker
	@echo "$(GREEN)Construindo imagens Docker...$(NC)"
	docker-compose build --no-cache

up: ## Inicia todos os serviços
	@echo "$(GREEN)Iniciando serviços...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Serviços iniciados!$(NC)"
	@echo "$(BLUE)Aplicação:$(NC) http://localhost:8080"
	@echo "$(BLUE)PHPMyAdmin:$(NC) http://localhost:8081"

down: ## Para todos os serviços
	@echo "$(RED)Parando serviços...$(NC)"
	docker-compose down

restart: ## Reinicia todos os serviços
	@echo "$(BLUE)Reiniciando serviços...$(NC)"
	docker-compose restart

logs: ## Mostra logs de todos os serviços
	docker-compose logs -f

logs-nginx: ## Mostra logs do Nginx
	docker-compose logs -f nginx

logs-php: ## Mostra logs das aplicações PHP
	docker-compose logs -f php-app-1 php-app-2 php-app-3

logs-mysql: ## Mostra logs do MySQL
	docker-compose logs -f mysql-db

status: ## Mostra status dos containers
	@echo "$(BLUE)Status dos containers:$(NC)"
	docker-compose ps

clean: ## Remove containers, volumes e imagens
	@echo "$(RED)Removendo containers, volumes e imagens...$(NC)"
	docker-compose down -v --rmi all
	@echo "$(GREEN)Limpeza concluída!$(NC)"

test: ## Testa a aplicação
	@echo "$(BLUE)Testando aplicação...$(NC)"
	@curl -s http://localhost:8080 > /dev/null && echo "$(GREEN)✓ Aplicação respondendo$(NC)" || echo "$(RED)✗ Aplicação não está respondendo$(NC)"
	@curl -s http://localhost:8080/health > /dev/null && echo "$(GREEN)✓ Health check OK$(NC)" || echo "$(RED)✗ Health check falhou$(NC)"

scale-php: ## Escala serviços PHP (uso: make scale-php N=5)
	@echo "$(BLUE)Escalando serviços PHP...$(NC)"
	docker-compose up -d --scale php-app-1=$(N) --scale php-app-2=$(N) --scale php-app-3=$(N)

shell-nginx: ## Acessa shell do container Nginx
	docker-compose exec nginx sh

shell-php: ## Acessa shell do container PHP (uso: make shell-php N=1)
	docker-compose exec php-app-$(N) bash

shell-mysql: ## Acessa shell do container MySQL
	docker-compose exec mysql-db mysql -u root -prootpassword meubanco

backup-db: ## Faz backup do banco de dados
	@echo "$(BLUE)Fazendo backup do banco de dados...$(NC)"
	docker-compose exec mysql-db mysqldump -u root -prootpassword meubanco > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup concluído!$(NC)"

install: build up ## Instala e inicia o projeto
	@echo "$(GREEN)Projeto instalado com sucesso!$(NC)"
	@echo "$(BLUE)Aguarde alguns segundos para os serviços iniciarem...$(NC)"
	@sleep 10
	@make test
