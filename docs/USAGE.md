# 🛠️ Guia de Uso - Projeto Toshiro Shibakita

Este documento explica como interagir com o projeto no dia a dia, utilizando os comandos do `Makefile` e entendendo a estrutura de diretórios.

## 1. Estrutura de Diretórios

O projeto está organizado da seguinte forma para garantir clareza e separação de responsabilidades:

```
/toshiro-shibakita-microsservicos
├── .env                  # Arquivo de variáveis de ambiente (NÃO versionar)
├── .gitignore            # Arquivos e diretórios a serem ignorados pelo Git
├── Makefile              # Comandos para automação de tarefas
├── README.md             # Documentação principal do projeto
├── docker-compose.yml    # Orquestração dos serviços para ambiente local
├── docker-compose.swarm.yml # Orquestração para deploy em Docker Swarm
|
├── /docs                 # Documentação adicional
│   ├── ARCHITECTURE.md   # Detalhes da arquitetura
│   ├── DEPLOYMENT.md     # Guia de deploy
│   └── USAGE.md          # Este guia
|
├── /mysql                # Configurações do serviço MySQL
│   ├── Dockerfile        # Dockerfile para a imagem customizada do MySQL
│   └── init.sql          # Script de inicialização do banco de dados
|
├── /nginx                # Configurações do serviço Nginx
│   ├── Dockerfile        # Dockerfile para a imagem do Nginx
│   └── nginx.conf        # Arquivo de configuração do Nginx (Load Balancer)
|
├── /php-app              # Código-fonte da aplicação PHP
│   ├── Dockerfile        # Dockerfile multi-stage para a aplicação
│   └── index.php         # Arquivo principal da aplicação
|
└── /scripts              # Scripts de automação e utilitários
    ├── deploy-aws.sh     # Script auxiliar para deploy na AWS
    └── swarm-init.sh     # Script para inicializar um cluster Swarm
```

## 2. Comandos do `Makefile`

O `Makefile` é a principal ferramenta para interagir com o ambiente Docker. Ele fornece atalhos para os comandos mais comuns do `docker-compose`.

Para ver todos os comandos disponíveis, execute:

```bash
make help
```

### Comandos Principais

| Comando         | Descrição                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------- |
| `make install`    | **(Recomendado para o primeiro uso)** Constrói as imagens e inicia todos os serviços.                     |
| `make up`         | Inicia todos os serviços (sem reconstruir as imagens).                                                |
| `make down`       | Para todos os serviços. Os dados do banco de dados (no volume) são preservados.                         |
| `make restart`    | Reinicia todos os serviços. Útil para aplicar alterações de configuração que não exigem rebuild.        |
| `make build`      | Força a reconstrução de todas as imagens Docker. Use após alterar um `Dockerfile`.                      |
| `make clean`      | **(Ação destrutiva)** Para todos os serviços, remove os containers, as redes, os volumes e as imagens. |

### Comandos de Debug e Monitoramento

| Comando         | Descrição                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------- |
| `make status`     | Mostra o status atual de todos os containers (rodando, parado, saudável, etc.).                         |
| `make logs`       | Exibe os logs de todos os serviços em tempo real (`-f`). Pressione `Ctrl+C` para sair.                  |
| `make logs-nginx` | Mostra os logs apenas do container do Nginx.                                                          |
| `make logs-php`   | Mostra os logs de todas as instâncias da aplicação PHP.                                                 |
| `make logs-mysql` | Mostra os logs do container do MySQL.                                                                 |

### Comandos de Interação

| Comando           | Descrição                                                                                             |
| ----------------- | ----------------------------------------------------------------------------------------------------- |
| `make shell-nginx`  | Abre um terminal (`sh`) dentro do container do Nginx.                                                   |
| `make shell-php N=1` | Abre um terminal (`bash`) dentro do container `php-app-1`. Mude o `N` para `2` ou `3` para acessar os outros. |
| `make shell-mysql`  | Abre um terminal (`bash`) dentro do container do MySQL.                                                 |
| `make mysql-cli`    | Abre o cliente de linha de comando do MySQL, já conectado ao banco `meubanco`.                        |

### Comandos de Teste e Manutenção

| Comando         | Descrição                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------- |
| `make test`       | Executa um `curl` para verificar se a aplicação está respondendo na porta `8080`.                       |
| `make backup-db`  | Executa um `mysqldump` dentro do container do MySQL e salva um arquivo de backup `.sql` no diretório raiz. |

## 3. Fluxo de Trabalho de Desenvolvimento

1.  **Inicie o ambiente**: Comece com `make install`.
2.  **Faça alterações no código**: Modifique os arquivos, por exemplo, o `index.php`.
3.  **Veja as alterações**: Como o diretório `php-app` está montado como um volume no `docker-compose.yml`, as alterações no `index.php` são refletidas instantaneamente. Basta recarregar a página no navegador.
4.  **Alterando `Dockerfile` ou `docker-compose.yml`**:
    -   Se você alterar um `Dockerfile`, precisa reconstruir a imagem com `make build` e depois reiniciar os serviços com `make up`.
    -   Se você alterar o `docker-compose.yml` (ex: adicionar uma porta ou variável de ambiente), basta executar `make up`. O Docker Compose irá detectar a mudança e recriar apenas os containers necessários.
5.  **Debugando**: Use `make logs` para ver os logs em tempo real ou `make shell-php N=1` para entrar em um container e investigar.
6.  **Finalizando o trabalho**: Execute `make down` para parar todos os containers.

## 4. Acessando o Banco de Dados

Existem duas maneiras principais de interagir com o banco de dados MySQL:

### a) Via PHPMyAdmin

-   Acesse [http://localhost:8081](http://localhost:8081)
-   **Servidor**: `mysql-db`
-   **Usuário**: `root`
-   **Senha**: `rootpassword` (definida no arquivo `.env`)

### b) Via Linha de Comando

Use o comando do `Makefile` para acessar o CLI do MySQL diretamente:

```bash
make mysql-cli
```

Uma vez dentro, você pode executar comandos SQL:

```sql
-- Exemplo:
SELECT Host, COUNT(*) as total FROM dados GROUP BY Host;

-- Para sair, digite:
exit;
```

---

*Este guia deve cobrir 99% dos casos de uso diário. Para funcionalidades mais avançadas, consulte a documentação oficial do Docker e do Docker Compose.*
