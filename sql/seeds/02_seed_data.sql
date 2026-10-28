-- 1. USUÁRIOS
INSERT INTO usuario (cpf, email, senha, p_nome, s_nome, telefone, data_nascimento, rua, numero, bairro, cidade, estado, cep, tipo_usuario) VALUES
('11111111101', 'carlos.gerente@decolae.com', 'hash_senha_gerente_123', 'Carlos', 'Drummond de Andrade', '31988887777', '1980-05-12', 'Rua das Flores', '100', 'Centro', 'Belo Horizonte', 'MG', '30100000', 'GERENTE'),
('22222222202', 'mariana.admin@decolae.com', 'hash_senha_admin_123', 'Mariana', 'Silva', '31977776666', '1990-08-20', 'Avenida Paulista', '1500', 'Bela Vista', 'São Paulo', 'SP', '01310100', 'ADMIN'),
('33333333303', 'lucas.cliente@email.com', 'hash_senha_cliente_123', 'Lucas', 'Menezes', '32999991111', '1995-03-15', 'Rua Tiradentes', '250', 'Fábricas', 'São João del-Rei', 'MG', '36300000', 'CLIENTE'),
('44444444404', 'beatriz.cliente@email.com', 'hash_senha_cliente_456', 'Beatriz', 'Ferreira', '21988882222', '1998-11-28', 'Rua Barata Ribeiro', '40', 'Copacabana', 'Rio de Janeiro', 'RJ', '22040000', 'CLIENTE');

-- 2. ESPECIALIZAÇÕES DE USUÁRIO
INSERT INTO gerente (cpf_gerente, matricula, departamento) VALUES
('11111111101', 'GER-001', 'Operações e Frota');

INSERT INTO admin (cpf_admin, matricula, turno, setor) VALUES
('22222222202', 'ADM-001', 'Matutino', 'Controlo de Malha Aérea');

INSERT INTO cliente (cpf_cliente, saldo_milhas) VALUES
('33333333303', 15000),
('44444444404', 5000);

-- 3. FROTA, ROTAS E TRIPULAÇÃO
INSERT INTO aeronave (identificacao_registro, modelo, capacidade, cpf_gerente_cadastro) VALUES
('PT-DEC', 'Airbus A320', 174, '11111111101'),
('PR-VOO', 'Boeing 737-800', 162, '11111111101');

INSERT INTO trajeto (cidade_origem, cidade_destino, horario_saida_padrao, horario_chegada_padrao, cpf_gerente_cadastro) VALUES
('Belo Horizonte (CNF)', 'São Paulo (GRU)', '08:00:00', '09:15:00', '11111111101'),
('São Paulo (GRU)', 'Rio de Janeiro (SDU)', '11:00:00', '12:00:00', '11111111101');

INSERT INTO tripulante (nome, funcao, cpf_gerente_cadastro) VALUES
('Comandante Marcos Pereira', 'PILOTO', '11111111101'),
('Primeiro Oficial Juliana Costa', 'COPILOTO', '11111111101'),
('Comissário Ricardo Neves', 'COMISSARIO', '11111111101'),
('Comissária Aline Rocha', 'COMISSARIO', '11111111101');

-- 4. VOOS
INSERT INTO voo (id_trajeto, id_aeronave, cpf_admin_criador, data_hora_partida, data_hora_chegada, status, assentos_disponiveis) VALUES
(1, 1, '22222222202', '2026-11-10 08:00:00', '2026-11-10 09:15:00', 'CONFIRMADO', 172),
(2, 2, '22222222202', '2026-11-10 11:00:00', '2026-11-10 12:00:00', 'PROGRAMADO', 162);

-- 5. ESCALAS DE TRIPULAÇÃO (Cumprindo o mínimo exigido: 1 piloto, 1 copiloto, 2 comissários)
INSERT INTO escala_tripulante_voo (id_voo, id_tripulante, papel_no_voo) VALUES
(1, 1, 'Comandante Responsável'),
(1, 2, 'Copiloto'),
(1, 3, 'Chefe de Cabine'),
(1, 4, 'Comissário Auxiliar');

-- 6. RESERVAS E COMPRA DE PASSAGENS
INSERT INTO passagem (id_voo, cpf_cliente, num_assento, preco_pago, status) VALUES
(1, '33333333303', '12A', 450.00, 'EMITIDA'),
(1, '44444444404', '12B', 450.00, 'EMITIDA');

-- 7. REGISTO DE LOG E AUDITORIA
INSERT INTO log_auditoria (cpf_usuario, tabela_afetada, operacao, dados_novos) VALUES
('22222222202', 'voo', 'INSERT', '{"id_voo": 1, "status": "CONFIRMADO"}'::jsonb);

INSERT INTO log_compra_passagem (cpf_cliente, id_voo, num_assento, resultado, mensagem) VALUES
('33333333303', 1, '12A', 'SUCESSO', 'Pagamento aprovado e assento reservado com sucesso.');