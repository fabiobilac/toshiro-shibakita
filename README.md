# 🚀 Projeto Toshiro Shibakita - Microsserviços com Docker

Este projeto é uma recriação e melhoria do desafio "Docker: Utilização prática no cenário de Microsserviços", inspirado na história de Toshiro Shibakita e proposto por Denilson Bonatti. O objetivo é demonstrar uma arquitetura de microsserviços robusta, escalável e pronta para produção, utilizando as melhores práticas do mercado.

## ✨ Melhorias Implementadas

Esta versão evolui o conceito original, abordando diversas limitações e introduzindo práticas modernas de desenvolvimento e DevOps:

- **Orquestração com Docker Compose**: Todos os serviços são gerenciados por um arquivo `docker-compose.yml`, facilitando o setup e a execução do ambiente completo com um único comando.
- **Separação de Serviços**: Cada componente (Nginx, PHP, MySQL) possui seu próprio `Dockerfile` e diretório, promovendo o isolamento e a manutenibilidade.
- **Variáveis de Ambiente**: Nenhuma credencial ou configuração sensível é "hardcoded". Tudo é gerenciado via variáveis de ambiente e um arquivo `.env`.
- **Redes Docker**: Foram criadas redes `frontend` e `backend` para garantir a comunicação segura e organizada entre os containers.
- **Persistência de Dados**: O banco de dados MySQL utiliza um volume nomeado (`mysql-data`) para garantir que os dados persistam mesmo que o container seja recriado.
- **Healthchecks**: Todos os serviços principais (Nginx, PHP, MySQL) possuem `healthchecks` configurados para garantir que o Docker possa monitorar e reiniciar containers que não estejam saudáveis.
- **Multi-Stage Builds**: O `Dockerfile` da aplicação PHP utiliza multi-stage builds para criar uma imagem de produção otimizada e segura, separada do ambiente de desenvolvimento.
- **Automação com `Makefile`**: Um `Makefile` completo foi adicionado para simplificar tarefas comuns como build, start, stop, visualização de logs e limpeza do ambiente.
- **Scripts de Deploy**: Foram criados scripts auxiliares em `scripts/` para facilitar o deploy em ambientes de nuvem (AWS) e a inicialização de um cluster Docker Swarm.
- **Interface Melhorada**: A aplicação `index.php` foi completamente redesenhada para oferecer uma interface mais rica, exibindo estatísticas de inserção por container e os últimos registros do banco de dados.

## 🏛️ Arquitetura Proposta

A arquitetura é composta por três camadas principais, orquestradas pelo Docker Compose:

1.  **Load Balancer (Nginx)**: Atua como a porta de entrada da aplicação. Recebe todas as requisições na porta `8080` e as distribui em modo `round-robin` entre as três instâncias da aplicação PHP.
2.  **Aplicação (PHP-Apache)**: Três containers idênticos da aplicação PHP rodam em paralelo para garantir alta disponibilidade e distribuição de carga. Cada container se conecta ao banco de dados para inserir e ler informações, registrando qual `hostname` (container) realizou a operação.
3.  **Banco de Dados (MySQL)**: Um único container MySQL serve como a camada de persistência. Ele é inicializado com um script `init.sql` que cria a tabela e insere dados de exemplo. Seus dados são armazenados em um volume para não serem perdidos.

![Arquitetura de Microsserviços](https://i.imgur.com/rV3s7v2.png)

## ⚙️ Como Executar o Projeto

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 1. Clone o Repositório

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd toshiro-shibakita-microsservicos
```

### 2. Inicie os Serviços

Utilize o `Makefile` para construir as imagens e iniciar todos os containers em modo `detached` (-d).

```bash
make install
```

Este comando irá executar os seguintes passos:
- `docker-compose build --no-cache`: Constrói as imagens a partir dos `Dockerfiles`.
- `docker-compose up -d`: Inicia todos os serviços em background.
- `make test`: Executa testes para verificar se a aplicação está no ar.

### 3. Acesse a Aplicação

- **Aplicação Principal**: Abra seu navegador e acesse [http://localhost:8080](http://localhost:8080)
    - Recarregue a página várias vezes para ver o `hostname` do container mudar, demonstrando o load balancing.
- **PHPMyAdmin**: Para gerenciar o banco de dados, acesse [http://localhost:8081](http://localhost:8081)
    - **Servidor**: `mysql-db`
    - **Usuário**: `root`
    - **Senha**: `rootpassword`

### 4. Comandos Úteis do `Makefile`

- `make help`: Mostra todos os comandos disponíveis.
- `make status`: Exibe o status atual dos containers.
- `make logs`: Exibe os logs de todos os serviços em tempo real.
- `make logs-nginx`: Exibe os logs apenas do Nginx.
- `make logs-php`: Exibe os logs das aplicações PHP.
- `make logs-mysql`: Exibe os logs do MySQL.
- `make down`: Para todos os serviços.
- `make clean`: Para todos os serviços e remove os volumes e imagens criadas.
- `make shell-php N=1`: Acessa o terminal do container `php-app-1`.

## ☁️ Deploy em Produção (Docker Swarm)

O projeto também está preparado para deploy em um ambiente de cluster com Docker Swarm.

1.  **Inicialize o Swarm**: Em seu nó *manager*, execute o script `swarm-init.sh`.
    ```bash
    ./scripts/swarm-init.sh
    ```
2.  **Adicione Workers**: O script exibirá um comando com um token. Execute este comando em outros nós para adicioná-los ao cluster como *workers*.
3.  **Deploy da Stack**: O script `swarm-init.sh` já faz o deploy da stack `toshiro` usando o arquivo `docker-compose.swarm.yml`.

Para mais detalhes sobre o deploy, consulte o arquivo `docs/DEPLOYMENT.md`.

---

*Este projeto foi desenvolvido como parte de um desafio prático e aprimorado para fins educacionais.*
