# 🏛️ Documentação de Arquitetura - Projeto Toshiro Shibakita

Este documento detalha as decisões de arquitetura tomadas na recriação do projeto Toshiro Shibakita, focando em criar um ambiente de microsserviços robusto, escalável e fácil de manter.

## 1. Visão Geral da Arquitetura

A arquitetura foi desenhada seguindo o padrão de **três camadas (3-Tier)**, um modelo bem estabelecido para aplicações web que separa a apresentação, a lógica de negócio e o armazenamento de dados.

| Camada          | Serviço        | Tecnologia       | Responsabilidade                                                                 |
| --------------- | -------------- | ---------------- | -------------------------------------------------------------------------------- |
| **Apresentação**  | `nginx`        | Nginx            | Atua como **Load Balancer** e **Reverse Proxy**, distribuindo o tráfego entre as instâncias da aplicação. |
| **Lógica**        | `php-app`      | PHP 8.2 + Apache | Executa a lógica de negócio, processa requisições, conecta-se ao banco de dados e gera a resposta. |
| **Dados**         | `mysql-db`     | MySQL 8.0        | Armazena e gerencia todos os dados da aplicação de forma persistente.            |

Este modelo foi implementado utilizando **containers Docker**, com cada serviço rodando em seu próprio container isolado, e a orquestração local é gerenciada pelo **Docker Compose**.

![Arquitetura de Microsserviços](https://i.imgur.com/rV3s7v2.png)

## 2. Estratégia de Containerização

Cada serviço foi containerizado com foco em otimização, segurança e reprodutibilidade.

### 2.1. Nginx (Load Balancer)

-   **Imagem Base**: `nginx:alpine`. A escolha da imagem `alpine` se deve ao seu tamanho reduzido, o que diminui a superfície de ataque e acelera o download da imagem.
-   **Configuração**: O arquivo `nginx.conf` é copiado para dentro da imagem, substituindo a configuração padrão. Ele define um `upstream` que aponta para os serviços da aplicação PHP, permitindo o load balancing.
-   **Healthcheck**: Um `HEALTHCHECK` foi adicionado para verificar se o processo do Nginx está rodando e respondendo, permitindo que o Docker reinicie o container em caso de falha.

### 2.2. Aplicação PHP

-   **Multi-Stage Build**: O `Dockerfile` da aplicação PHP utiliza uma abordagem de **multi-stage build** para criar ambientes distintos de desenvolvimento e produção.
    -   **`base` stage**: Instala as dependências comuns, como as extensões `mysqli` e `pdo_mysql`.
    -   **`production` stage**: Herda do `base` e aplica configurações de segurança, como desabilitar a exibição de erros (`display_errors = Off`) e desativar a exposição da versão do PHP (`expose_php = Off`).
    -   **`development` stage**: Herda do `base` e habilita a exibição de erros para facilitar o debug.
    O `docker-compose.yml` utiliza o `target: production` para garantir que a imagem final seja a de produção, que é mais segura e otimizada.
-   **Imagem Base**: `php:8.2-apache`. Esta imagem já vem com o Apache configurado para servir arquivos PHP, simplificando o setup.

### 2.3. Banco de Dados MySQL

-   **Imagem Base**: `mysql:8.0`. Utiliza a imagem oficial do MySQL, que é mantida e atualizada pela comunidade.
-   **Inicialização**: Um script `init.sql` é montado no diretório `/docker-entrypoint-initdb.d/`. O entrypoint da imagem oficial do MySQL executa automaticamente qualquer script `.sql` neste diretório na primeira vez que o container é iniciado. Isso garante que o banco de dados e a tabela `dados` sejam criados e populados no momento do setup.
-   **Configuração Customizada**: Um arquivo `custom.cnf` é adicionado para definir configurações específicas do MySQL, como `max_connections`, `character-set` e `time-zone`, garantindo consistência no ambiente.

## 3. Rede (Networking)

A comunicação entre os containers é gerenciada por redes customizadas do Docker, o que oferece maior segurança e organização do que a rede `bridge` padrão.

-   **`frontend-network`**: Uma rede do tipo `bridge` que conecta o **Load Balancer (Nginx)** e as **instâncias da aplicação PHP**. O Nginx utiliza esta rede para descobrir e encaminhar tráfego para os containers da aplicação.
-   **`backend-network`**: Uma rede `bridge` que conecta as **instâncias da aplicação PHP** e o **banco de dados MySQL**. Esta rede isola o banco de dados, garantindo que ele só possa ser acessado pelos serviços da aplicação, e não diretamente pelo Nginx ou de fora do ambiente Docker (exceto pela porta exposta do PHPMyAdmin).

Essa separação impede, por exemplo, que um ataque que comprometa o Load Balancer tenha acesso direto ao banco de dados, aumentando a segurança geral da arquitetura.

## 4. Persistência de Dados

Para garantir que os dados do banco de dados não sejam perdidos quando um container é removido ou recriado, foi implementada uma estratégia de persistência utilizando **volumes nomeados** do Docker.

-   **Volume `mysql-data`**: O `docker-compose.yml` define um volume chamado `mysql-data` e o monta no diretório `/var/lib/mysql` dentro do container do MySQL. Este é o diretório onde o MySQL armazena todos os seus arquivos de dados.

Ao usar um volume nomeado, o ciclo de vida dos dados é desvinculado do ciclo de vida do container. Mesmo que o comando `docker-compose down` seja executado, o volume `mysql-data` não é removido (a menos que a flag `-v` seja usada), e os dados estarão disponíveis na próxima vez que o serviço for iniciado com `docker-compose up`.

## 5. Configuração e Segredos

Seguindo as melhores práticas de **12-Factor App**, todas as configurações que variam entre ambientes (desenvolvimento, produção, etc.) são gerenciadas por **variáveis de ambiente**.

-   **Arquivo `.env`**: O Docker Compose lê automaticamente um arquivo chamado `.env` no diretório raiz e torna as variáveis definidas nele disponíveis para o `docker-compose.yml` e, consequentemente, para os containers.
-   **Credenciais**: Senhas de banco de dados (`MYSQL_ROOT_PASSWORD`, `DB_PASSWORD`) e outras informações sensíveis são definidas no arquivo `.env`, que **não deve ser versionado** no Git (está incluído no `.gitignore`).
-   **Aplicação PHP**: O `index.php` foi modificado para ler as configurações de conexão com o banco de dados a partir de variáveis de ambiente usando a função `getenv()`. Isso torna a aplicação portátil e segura, sem credenciais "hardcoded".

## 6. Escalabilidade e Alta Disponibilidade

A arquitetura foi projetada para ser escalável horizontalmente.

-   **Múltiplas Instâncias PHP**: O `docker-compose.yml` define três serviços `php-app` (`php-app-1`, `php-app-2`, `php-app-3`). O Nginx distribui a carga entre eles, o que já simula um ambiente de alta disponibilidade.
-   **Docker Swarm**: Para um ambiente de produção real, o arquivo `docker-compose.swarm.yml` está preparado para deploy em um cluster **Docker Swarm**. Nele, a escalabilidade é gerenciada de forma declarativa:
    ```yaml
    deploy:
      replicas: 3
    ```
    Com o Swarm, é possível escalar o número de réplicas de um serviço com um único comando (`docker service scale toshiro_php-app=5`), e o orquestrador se encarrega de distribuir os containers pelos nós do cluster.

---

*Esta documentação reflete as melhores práticas de mercado para o desenvolvimento de aplicações containerizadas, visando criar um sistema resiliente, seguro e fácil de operar.*
