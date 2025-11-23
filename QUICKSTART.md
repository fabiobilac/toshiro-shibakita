# ⚡ Guia de Início Rápido - Projeto Toshiro Shibakita

Este guia permite que você execute o projeto em menos de 5 minutos!

## 🚀 Passo a Passo

### 1. Pré-requisitos

Certifique-se de ter instalado:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 2. Extrair o Projeto

Se você recebeu o arquivo compactado, extraia-o:

```bash
tar -xzf toshiro-shibakita-microsservicos.tar.gz
cd toshiro-shibakita-microsservicos
```

### 3. Iniciar o Projeto

Execute um único comando:

```bash
make install
```

Este comando irá:
- ✅ Construir todas as imagens Docker
- ✅ Iniciar todos os serviços
- ✅ Verificar se a aplicação está funcionando

### 4. Acessar a Aplicação

Abra seu navegador em:

- **Aplicação Principal**: [http://localhost:8080](http://localhost:8080)
- **PHPMyAdmin**: [http://localhost:8081](http://localhost:8081)
  - Servidor: `mysql-db`
  - Usuário: `root`
  - Senha: `rootpassword`

### 5. Testar o Load Balancing

Recarregue a página [http://localhost:8080](http://localhost:8080) várias vezes e observe o campo **"Hostname"** mudando. Isso demonstra que o Nginx está distribuindo as requisições entre os 3 containers PHP!

## 📋 Comandos Úteis

```bash
# Ver status dos containers
make status

# Ver logs em tempo real
make logs

# Parar todos os serviços
make down

# Reiniciar serviços
make restart

# Ver todos os comandos disponíveis
make help
```

## 🎯 Próximos Passos

Explore a documentação completa em:
- **README.md**: Visão geral do projeto
- **docs/ARCHITECTURE.md**: Detalhes da arquitetura
- **docs/DEPLOYMENT.md**: Guia de deploy em produção
- **docs/USAGE.md**: Guia completo de uso

## 🐛 Problemas?

Se encontrar algum erro:

1. Verifique se o Docker está rodando: `docker ps`
2. Veja os logs: `make logs`
3. Reinicie o ambiente: `make down && make up`

---

**Pronto!** Você já tem um ambiente completo de microsserviços rodando! 🎉
