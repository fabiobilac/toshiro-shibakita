# ☁️ Guia de Deploy - Projeto Toshiro Shibakita

Este guia fornece instruções detalhadas para fazer o deploy da aplicação em diferentes ambientes: localmente com Docker Compose e em um cluster com Docker Swarm.

## 1. Deploy Local com Docker Compose

Este é o método recomendado para desenvolvimento e testes. Ele simula a arquitetura de microsserviços em sua máquina local.

### Pré-requisitos

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [Git](https://git-scm.com/downloads)

### Passo a Passo

1.  **Clonar o Repositório**

    ```bash
    git clone https://github.com/seu-usuario/toshiro-shibakita-microsservicos.git
    cd toshiro-shibakita-microsservicos
    ```

2.  **Configurar Variáveis de Ambiente**

    O projeto já vem com um arquivo `.env` com valores padrão. Se desejar, você pode customizar as senhas e portas.

    ```dotenv
    # .env
    MYSQL_ROOT_PASSWORD=rootpassword
    MYSQL_DATABASE=meubanco
    NGINX_PORT=8080
    PHPMYADMIN_PORT=8081
    ```

3.  **Construir e Iniciar os Serviços**

    O `Makefile` simplifica este processo. Execute o comando `install`:

    ```bash
    make install
    ```

    Este comando irá executar os seguintes passos:
    -   Construir as imagens Docker para cada serviço (`nginx`, `php-app`, `mysql-db`).
    -   Iniciar todos os containers em background.
    -   Aguardar 10 segundos para a inicialização dos serviços.
    -   Executar testes de conectividade.

4.  **Verificar o Status**

    Use o comando `make status` para ver se todos os containers estão rodando e saudáveis (`healthy`).

    ```bash
    make status
    ```

    A saída deve ser semelhante a esta:

    ```
    NAME                   COMMAND                  SERVICE             STATUS              PORTS
    nginx-loadbalancer     "nginx -g 'daemon of…"   nginx               running (healthy)   0.0.0.0:8080->80/tcp
    php-app-1              "docker-php-entrypoi…"   php-app-1           running (healthy)
    php-app-2              "docker-php-entrypoi…"   php-app-2           running (healthy)
    php-app-3              "docker-php-entrypoi…"   php-app-3           running (healthy)
    mysql-db               "docker-entrypoint.s…"   mysql-db            running (healthy)   3306/tcp
    phpmyadmin             "/docker-entrypoint.…"   phpmyadmin          running             0.0.0.0:8081->80/tcp
    ```

5.  **Acessar a Aplicação**

    -   **Aplicação**: [http://localhost:8080](http://localhost:8080)
    -   **PHPMyAdmin**: [http://localhost:8081](http://localhost:8081)

## 2. Deploy em Produção com Docker Swarm

Docker Swarm é o orquestrador de containers nativo do Docker, ideal para ambientes de produção. Ele permite gerenciar um cluster de máquinas (nós) como se fossem uma só.

### Pré-requisitos

-   Pelo menos duas máquinas (físicas ou virtuais, como instâncias EC2 na AWS) com Docker instalado. Uma será o `manager` e as outras, `workers`.
-   As portas necessárias devem estar abertas no firewall/security group entre os nós:
    -   **TCP 2377**: Para comunicação de gerenciamento do cluster.
    -   **TCP/UDP 7946**: Para comunicação entre os nós.
    -   **UDP 4789**: Para o tráfego da rede overlay.

### Passo a Passo

1.  **Inicializar o Swarm (no nó Manager)**

    Conecte-se via SSH à máquina que será o seu `manager` e execute:

    ```bash
    # Substitua <MANAGER_IP> pelo IP da sua máquina manager
    docker swarm init --advertise-addr <MANAGER_IP>
    ```

    O Docker exibirá um comando para adicionar nós `worker` ao cluster. Copie este comando.

2.  **Adicionar Nós Workers**

    Conecte-se via SSH a cada uma das outras máquinas e cole o comando gerado no passo anterior.

    ```bash
    docker swarm join --token <TOKEN> <MANAGER_IP>:2377
    ```

    De volta ao nó `manager`, verifique se os nós foram adicionados com sucesso:

    ```bash
    docker node ls
    ```

3.  **Clonar o Repositório (no nó Manager)**

    No nó `manager`, clone o repositório do projeto.

    ```bash
    git clone https://github.com/seu-usuario/toshiro-shibakita-microsservicos.git
    cd toshiro-shibakita-microsservicos
    ```

4.  **Construir e Disponibilizar as Imagens**

    Em um ambiente de produção, as imagens devem estar disponíveis para todos os nós do cluster. A melhor maneira de fazer isso é usando um **Registry de Imagens**, como o Docker Hub, AWS ECR ou um registry privado.

    a.  **Fazer login no registry** (ex: Docker Hub):
        ```bash
        docker login
        ```

    b.  **Construir, Taguear e Enviar cada imagem**:
        ```bash
        # Exemplo para o Nginx
        docker build -t seu-usuario/toshiro-nginx:latest ./nginx
        docker push seu-usuario/toshiro-nginx:latest

        # Repita para php-app e mysql-db
        docker build -t seu-usuario/toshiro-php:latest ./php-app
        docker push seu-usuario/toshiro-php:latest

        docker build -t seu-usuario/toshiro-mysql:latest ./mysql
        docker push seu-usuario/toshiro-mysql:latest
        ```

    c.  **Atualizar o `docker-compose.swarm.yml`**: Altere os nomes das imagens para usar as que você enviou para o registry.
        ```yaml
        services:
          nginx:
            image: seu-usuario/toshiro-nginx:latest
          php-app:
            image: seu-usuario/toshiro-php:latest
          mysql-db:
            image: seu-usuario/toshiro-mysql:latest
        ```

5.  **Fazer o Deploy da Stack**

    Agora, no nó `manager`, execute o deploy da stack usando o arquivo de compose para Swarm:

    ```bash
    docker stack deploy -c docker-compose.swarm.yml toshiro
    ```

    O Docker Swarm irá baixar as imagens e distribuir os containers pelos nós do cluster, conforme as regras de `placement` definidas no arquivo.

6.  **Verificar o Deploy**

    -   **Verificar os serviços da stack**:
        ```bash
        docker stack services toshiro
        ```
    -   **Verificar os containers em execução**:
        ```bash
        docker stack ps toshiro
        ```

7.  **Acessar a Aplicação**

    Acesse o IP de **qualquer nó** do cluster na porta `80` (ou na porta que você expôs para o serviço `nginx`). O `Routing Mesh` do Swarm garantirá que sua requisição seja encaminhada para um container do Nginx, não importa em qual nó ele esteja rodando.

    -   **Aplicação**: `http://<IP_DE_QUALQUER_NO>`

### Script de Automação

O script `scripts/swarm-init.sh` automatiza os passos 1, 3 e 5 (para um ambiente de teste local com Swarm). Ele pode ser adaptado para um deploy em produção.

---

*Este guia cobre os cenários mais comuns de deploy. Para ambientes mais complexos, considere o uso de ferramentas de CI/CD como GitHub Actions, GitLab CI ou Jenkins para automatizar o processo de build, teste e deploy.*
