<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Microsserviços Docker - Toshiro Shibakita</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 {
            color: #667eea;
            text-align: center;
            margin-bottom: 30px;
        }
        .info-box {
            background: #f8f9fa;
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid #667eea;
            border-radius: 5px;
        }
        .success {
            background: #d4edda;
            border-left-color: #28a745;
            color: #155724;
        }
        .error {
            background: #f8d7da;
            border-left-color: #dc3545;
            color: #721c24;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #667eea;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Microsserviços com Docker</h1>
        <h2 style="text-align: center; color: #764ba2;">A História de Toshiro Shibakita</h2>

<?php
// Configurações usando variáveis de ambiente
$servername = getenv('DB_HOST') ?: 'mysql-db';
$username = getenv('DB_USER') ?: 'root';
$password = getenv('DB_PASSWORD') ?: 'rootpassword';
$database = getenv('DB_NAME') ?: 'meubanco';

// Informações do sistema
$hostname = gethostname();
$php_version = phpversion();
$server_ip = $_SERVER['SERVER_ADDR'] ?? 'N/A';
$client_ip = $_SERVER['REMOTE_ADDR'] ?? 'N/A';

echo '<div class="info-box">';
echo '<h3>📊 Informações do Container</h3>';
echo '<strong>Hostname:</strong> ' . htmlspecialchars($hostname) . '<br>';
echo '<strong>IP do Servidor:</strong> ' . htmlspecialchars($server_ip) . '<br>';
echo '<strong>IP do Cliente:</strong> ' . htmlspecialchars($client_ip) . '<br>';
echo '<strong>Versão do PHP:</strong> ' . htmlspecialchars($php_version) . '<br>';
echo '<strong>Timestamp:</strong> ' . date('Y-m-d H:i:s') . '<br>';
echo '</div>';

// Tentar conexão com o banco de dados
try {
    $link = new mysqli($servername, $username, $password, $database);
    
    if ($link->connect_errno) {
        throw new Exception($link->connect_error);
    }
    
    echo '<div class="info-box success">';
    echo '<h3>✅ Conexão com MySQL</h3>';
    echo '<strong>Status:</strong> Conectado com sucesso!<br>';
    echo '<strong>Host:</strong> ' . htmlspecialchars($servername) . '<br>';
    echo '<strong>Database:</strong> ' . htmlspecialchars($database) . '<br>';
    echo '<strong>Versão do MySQL:</strong> ' . $link->server_info . '<br>';
    echo '</div>';
    
    // Gerar dados aleatórios
    $valor_rand1 = rand(1000, 9999);
    $nome_rand = 'Aluno_' . strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
    $sobrenome_rand = 'Silva_' . rand(100, 999);
    $endereco_rand = 'Rua ' . rand(1, 1000) . ', Centro';
    $cidade_rand = ['São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasília', 'Porto Alegre'][rand(0, 4)];
    
    // Preparar e executar query
    $stmt = $link->prepare("INSERT INTO dados (AlunoID, Nome, Sobrenome, Endereco, Cidade, Host) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("isssss", $valor_rand1, $nome_rand, $sobrenome_rand, $endereco_rand, $cidade_rand, $hostname);
    
    if ($stmt->execute()) {
        echo '<div class="info-box success">';
        echo '<h3>✅ Registro Inserido</h3>';
        echo '<strong>AlunoID:</strong> ' . $valor_rand1 . '<br>';
        echo '<strong>Nome:</strong> ' . htmlspecialchars($nome_rand) . '<br>';
        echo '<strong>Sobrenome:</strong> ' . htmlspecialchars($sobrenome_rand) . '<br>';
        echo '<strong>Cidade:</strong> ' . htmlspecialchars($cidade_rand) . '<br>';
        echo '<strong>Container:</strong> ' . htmlspecialchars($hostname) . '<br>';
        echo '</div>';
    } else {
        throw new Exception($stmt->error);
    }
    
    $stmt->close();
    
    // Buscar últimos 10 registros
    $result = $link->query("SELECT * FROM dados ORDER BY AlunoID DESC LIMIT 10");
    
    if ($result && $result->num_rows > 0) {
        echo '<h3>📋 Últimos 10 Registros</h3>';
        echo '<table>';
        echo '<tr><th>ID</th><th>Nome</th><th>Sobrenome</th><th>Cidade</th><th>Container</th></tr>';
        
        while ($row = $result->fetch_assoc()) {
            echo '<tr>';
            echo '<td>' . htmlspecialchars($row['AlunoID']) . '</td>';
            echo '<td>' . htmlspecialchars($row['Nome']) . '</td>';
            echo '<td>' . htmlspecialchars($row['Sobrenome']) . '</td>';
            echo '<td>' . htmlspecialchars($row['Cidade']) . '</td>';
            echo '<td><strong>' . htmlspecialchars($row['Host']) . '</strong></td>';
            echo '</tr>';
        }
        
        echo '</table>';
        
        // Estatísticas por container
        $stats = $link->query("SELECT Host, COUNT(*) as total FROM dados GROUP BY Host ORDER BY total DESC");
        
        if ($stats && $stats->num_rows > 0) {
            echo '<h3>📈 Estatísticas por Container</h3>';
            echo '<table>';
            echo '<tr><th>Container</th><th>Total de Registros</th></tr>';
            
            while ($row = $stats->fetch_assoc()) {
                echo '<tr>';
                echo '<td><strong>' . htmlspecialchars($row['Host']) . '</strong></td>';
                echo '<td>' . $row['total'] . '</td>';
                echo '</tr>';
            }
            
            echo '</table>';
        }
    }
    
    $link->close();
    
} catch (Exception $e) {
    echo '<div class="info-box error">';
    echo '<h3>❌ Erro de Conexão</h3>';
    echo '<strong>Mensagem:</strong> ' . htmlspecialchars($e->getMessage()) . '<br>';
    echo '<strong>Host tentado:</strong> ' . htmlspecialchars($servername) . '<br>';
    echo '</div>';
}
?>

        <div class="footer">
            <p><strong>🚀 Projeto Toshiro Shibakita - Microsserviços com Docker</strong></p>
            <p>Demonstração de Load Balancing, Containerização e Alta Disponibilidade</p>
            <p>Recarregue a página para ver requisições sendo distribuídas entre diferentes containers!</p>
        </div>
    </div>
</body>
</html>
