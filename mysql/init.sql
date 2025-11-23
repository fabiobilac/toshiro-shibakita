-- Script de inicialização do banco de dados
-- Projeto Toshiro Shibakita - Microsserviços com Docker

-- Criar banco de dados se não existir
CREATE DATABASE IF NOT EXISTS meubanco CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE meubanco;

-- Criar tabela de dados
CREATE TABLE IF NOT EXISTS dados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    AlunoID INT NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Sobrenome VARCHAR(50) NOT NULL,
    Endereco VARCHAR(150),
    Cidade VARCHAR(50),
    Host VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_aluno (AlunoID),
    INDEX idx_host (Host),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserir dados de exemplo
INSERT INTO dados (AlunoID, Nome, Sobrenome, Endereco, Cidade, Host) VALUES
(1001, 'Toshiro', 'Shibakita', 'Rua das Flores, 123', 'São Paulo', 'container-inicial'),
(1002, 'Maria', 'Silva', 'Av. Paulista, 1000', 'São Paulo', 'container-inicial'),
(1003, 'João', 'Santos', 'Rua do Comércio, 456', 'Rio de Janeiro', 'container-inicial'),
(1004, 'Ana', 'Costa', 'Av. Brasil, 2000', 'Belo Horizonte', 'container-inicial'),
(1005, 'Pedro', 'Oliveira', 'Rua Central, 789', 'Brasília', 'container-inicial');

-- Criar usuário para a aplicação (se não existir)
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON meubanco.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

-- Exibir informações
SELECT 'Banco de dados inicializado com sucesso!' AS Status;
SELECT COUNT(*) AS Total_Registros FROM dados;
