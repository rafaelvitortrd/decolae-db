CREATE TABLE IF NOT EXISTS usuario (
    cpf VARCHAR(11) PRIMARY KEY,
    email VARCHAR(120) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    p_nome VARCHAR(50) NOT NULL,
    s_nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    data_nascimento DATE NOT NULL,
    rua VARCHAR(150),
    numero VARCHAR(20),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(8),
    tipo_usuario VARCHAR(15) NOT NULL CHECK (tipo_usuario IN ('CLIENTE', 'GERENTE', 'ADMIN')),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cliente (
    cpf_cliente VARCHAR(11) PRIMARY KEY REFERENCES usuario(cpf) ON DELETE CASCADE,
    saldo_milhas INT DEFAULT 0 CHECK (saldo_milhas >= 0)
);

CREATE TABLE IF NOT EXISTS gerente (
    cpf_gerente VARCHAR(11) PRIMARY KEY REFERENCES usuario(cpf) ON DELETE CASCADE,
    matricula VARCHAR(30) UNIQUE NOT NULL,
    departamento VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS admin (
    cpf_admin VARCHAR(11) PRIMARY KEY REFERENCES usuario(cpf) ON DELETE CASCADE,
    matricula VARCHAR(30) UNIQUE NOT NULL,
    turno VARCHAR(30),
    setor VARCHAR(80)
);

CREATE TABLE IF NOT EXISTS aeronave (
    id_aeronave SERIAL PRIMARY KEY,
    identificacao_registro VARCHAR(30) UNIQUE NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    capacidade INT NOT NULL CHECK (capacidade > 0),
    cpf_gerente_cadastro VARCHAR(11) REFERENCES gerente(cpf_gerente) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS trajeto (
    id_trajeto SERIAL PRIMARY KEY,
    cidade_origem VARCHAR(100) NOT NULL,
    cidade_destino VARCHAR(100) NOT NULL,
    horario_saida_padrao TIME NOT NULL,
    horario_chegada_padrao TIME NOT NULL,
    cpf_gerente_cadastro VARCHAR(11) REFERENCES gerente(cpf_gerente) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS tripulante (
    id_tripulante SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    funcao VARCHAR(50) NOT NULL CHECK (funcao IN ('PILOTO', 'COPILOTO', 'COMISSARIO')),
    cpf_gerente_cadastro VARCHAR(11) REFERENCES gerente(cpf_gerente) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS voo (
    id_voo SERIAL PRIMARY KEY,
    id_trajeto INT NOT NULL REFERENCES trajeto(id_trajeto) ON DELETE RESTRICT,
    id_aeronave INT NOT NULL REFERENCES aeronave(id_aeronave) ON DELETE RESTRICT,
    cpf_admin_criador VARCHAR(11) NOT NULL REFERENCES admin(cpf_admin) ON DELETE RESTRICT,
    data_hora_partida TIMESTAMP NOT NULL,
    data_hora_chegada TIMESTAMP NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PROGRAMADO' CHECK (status IN ('PROGRAMADO', 'CONFIRMADO', 'CANCELADO', 'FINALIZADO')),
    assentos_disponiveis INT NOT NULL CHECK (assentos_disponiveis >= 0),
    CONSTRAINT chk_horarios_voo CHECK (data_hora_chegada > data_hora_partida)
);

CREATE TABLE IF NOT EXISTS escala_tripulante_voo (
    id_voo INT NOT NULL REFERENCES voo(id_voo) ON DELETE CASCADE,
    id_tripulante INT NOT NULL REFERENCES tripulante(id_tripulante) ON DELETE RESTRICT,
    papel_no_voo VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_voo, id_tripulante)
);

CREATE TABLE IF NOT EXISTS passagem (
    id_passagem SERIAL PRIMARY KEY,
    id_voo INT NOT NULL REFERENCES voo(id_voo) ON DELETE RESTRICT,
    cpf_cliente VARCHAR(11) NOT NULL REFERENCES cliente(cpf_cliente) ON DELETE RESTRICT,
    num_assento VARCHAR(5) NOT NULL,
    preco_pago NUMERIC(10, 2) NOT NULL CHECK (preco_pago > 0),
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'EMITIDA' CHECK (status IN ('EMITIDA', 'CANCELADA', 'UTILIZADA')),
    CONSTRAINT uq_voo_assento UNIQUE (id_voo, num_assento)
);

CREATE TABLE IF NOT EXISTS log_auditoria (
    id_log SERIAL PRIMARY KEY,
    cpf_usuario VARCHAR(11) REFERENCES usuario(cpf) ON DELETE SET NULL,
    tabela_afetada VARCHAR(50) NOT NULL,
    operacao VARCHAR(20) NOT NULL CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_anteriores JSONB,
    dados_novos JSONB
);

CREATE TABLE IF NOT EXISTS log_compra_passagem (
    id_tentativa SERIAL PRIMARY KEY,
    cpf_cliente VARCHAR(11) NOT NULL,
    id_voo INT NOT NULL,
    num_assento VARCHAR(5),
    resultado VARCHAR(30) NOT NULL CHECK (resultado IN ('SUCESSO', 'FALHA_ESGOTADO', 'FALHA_CONCORRENCIA', 'ERRO')),
    mensagem TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);