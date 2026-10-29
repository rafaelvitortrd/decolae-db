-- Decolae - Parte 2: povoamento inicial
-- Compativel com 01_create_tables.sql enviado pelo grupo.
-- EXECUTE APENAS UMA VEZ, EM UM BANCO decolae COM AS TABELAS VAZIAS.
-- CPFs, senhas e e-mails sao dados ficticios para demonstracao.
-- As senhas abaixo NAO sao hashes reais: nao utilizar para autenticacao.

BEGIN;

-- 1. USUARIOS (6: 2 gerentes, 2 administradores, 2 clientes)
INSERT INTO usuario
    (cpf, email, senha, p_nome, s_nome, telefone, data_nascimento,
     rua, numero, bairro, cidade, estado, cep, tipo_usuario)
VALUES
('11111111101', 'carlos.gerente@decolae.example', 'senha_demo_gerente_1',
 'Carlos', 'Andrade', '31988887777', '1980-05-12',
 'Rua das Flores', '100', 'Centro', 'Belo Horizonte', 'MG', '30100000', 'GERENTE'),
('55555555505', 'patricia.gerente@decolae.example', 'senha_demo_gerente_2',
 'Patricia', 'Almeida', '31988886666', '1985-02-10',
 'Rua do Comercio', '225', 'Centro', 'Contagem', 'MG', '32000000', 'GERENTE'),
('22222222202', 'mariana.admin@decolae.example', 'senha_demo_admin_1',
 'Mariana', 'Silva', '31977776666', '1990-08-20',
 'Avenida Paulista', '1500', 'Bela Vista', 'Sao Paulo', 'SP', '01310100', 'ADMIN'),
('66666666606', 'rodrigo.admin@decolae.example', 'senha_demo_admin_2',
 'Rodrigo', 'Lima', '11977775555', '1989-06-22',
 'Rua Vergueiro', '320', 'Liberdade', 'Sao Paulo', 'SP', '01504000', 'ADMIN'),
('33333333303', 'lucas.cliente@decolae.example', 'senha_demo_cliente_1',
 'Lucas', 'Menezes', '32999991111', '1995-03-15',
 'Rua Tiradentes', '250', 'Fabricas', 'Sao Joao del-Rei', 'MG', '36300000', 'CLIENTE'),
('44444444404', 'beatriz.cliente@decolae.example', 'senha_demo_cliente_2',
 'Beatriz', 'Ferreira', '21988882222', '1998-11-28',
 'Rua Barata Ribeiro', '40', 'Copacabana', 'Rio de Janeiro', 'RJ', '22040000', 'CLIENTE');

-- 2. ESPECIALIZACOES
INSERT INTO gerente (cpf_gerente, matricula, departamento) VALUES
('11111111101', 'GER-001', 'Operacoes e Frota'),
('55555555505', 'GER-002', 'Planejamento de Rotas');

INSERT INTO admin (cpf_admin, matricula, turno, setor) VALUES
('22222222202', 'ADM-001', 'Matutino', 'Controle de Malha Aerea'),
('66666666606', 'ADM-002', 'Vespertino', 'Operacoes de Voo');

INSERT INTO cliente (cpf_cliente, saldo_milhas) VALUES
('33333333303', 15000),
('44444444404', 5000);

-- 3. FROTA, TRAJETOS E TRIPULANTES
-- Usaremos consultas para localizar os IDs gerados automaticamente.
INSERT INTO aeronave
    (identificacao_registro, modelo, capacidade, cpf_gerente_cadastro)
VALUES
('PT-DEC', 'Airbus A320', 174, '11111111101'),
('PR-VOO', 'Boeing 737-800', 162, '11111111101'),
('PR-EXP', 'Embraer E195-E2', 136, '55555555505');

INSERT INTO trajeto
    (cidade_origem, cidade_destino, horario_saida_padrao,
     horario_chegada_padrao, cpf_gerente_cadastro)
VALUES
('Belo Horizonte (CNF)', 'Sao Paulo (GRU)', '08:00:00', '09:15:00', '11111111101'),
('Sao Paulo (GRU)', 'Rio de Janeiro (SDU)', '11:00:00', '12:00:00', '11111111101'),
('Rio de Janeiro (SDU)', 'Belo Horizonte (CNF)', '15:00:00', '16:10:00', '55555555505');

-- Duas equipes diferentes, evitando escala em dois voos no mesmo dia.
INSERT INTO tripulante (nome, funcao, cpf_gerente_cadastro) VALUES
('Marcos Pereira', 'PILOTO', '11111111101'),
('Juliana Costa', 'COPILOTO', '11111111101'),
('Ricardo Neves', 'COMISSARIO', '11111111101'),
('Aline Rocha', 'COMISSARIO', '11111111101'),
('Pedro Martins', 'PILOTO', '55555555505'),
('Fernanda Oliveira', 'COPILOTO', '55555555505'),
('Caio Santos', 'COMISSARIO', '55555555505'),
('Bruna Souza', 'COMISSARIO', '55555555505');

-- 4. VOOS
-- Voo 1: capacidade 174 - 2 passagens ativas = 172 disponiveis.
-- Voo 2: capacidade 162 - 1 passagem ativa = 161 disponiveis.
INSERT INTO voo
    (id_trajeto, id_aeronave, cpf_admin_criador,
     data_hora_partida, data_hora_chegada, status, assentos_disponiveis)
VALUES
((SELECT id_trajeto FROM trajeto
  WHERE cidade_origem = 'Belo Horizonte (CNF)' AND cidade_destino = 'Sao Paulo (GRU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PT-DEC'),
 '22222222202', '2026-11-10 08:00:00', '2026-11-10 09:15:00',
 'CONFIRMADO', 172),
((SELECT id_trajeto FROM trajeto
  WHERE cidade_origem = 'Sao Paulo (GRU)' AND cidade_destino = 'Rio de Janeiro (SDU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-VOO'),
 '66666666606', '2026-11-10 11:00:00', '2026-11-10 12:00:00',
 'PROGRAMADO', 161);

-- 5. ESCALAS (4 profissionais por voo)
-- Associacao por data/hora de partida e nome: nao depende dos IDs SERIAL.
INSERT INTO escala_tripulante_voo (id_voo, id_tripulante, papel_no_voo)
SELECT v.id_voo, t.id_tripulante, dados.papel
FROM (VALUES
    ('2026-11-10 08:00:00'::timestamp, 'Marcos Pereira', 'Piloto'),
    ('2026-11-10 08:00:00'::timestamp, 'Juliana Costa', 'Copiloto'),
    ('2026-11-10 08:00:00'::timestamp, 'Ricardo Neves', 'Comissario'),
    ('2026-11-10 08:00:00'::timestamp, 'Aline Rocha', 'Comissario'),
    ('2026-11-10 11:00:00'::timestamp, 'Pedro Martins', 'Piloto'),
    ('2026-11-10 11:00:00'::timestamp, 'Fernanda Oliveira', 'Copiloto'),
    ('2026-11-10 11:00:00'::timestamp, 'Caio Santos', 'Comissario'),
    ('2026-11-10 11:00:00'::timestamp, 'Bruna Souza', 'Comissario')
) AS dados(partida, nome, papel)
JOIN voo v ON v.data_hora_partida = dados.partida
JOIN tripulante t ON t.nome = dados.nome;

-- 6. PASSAGENS (3)
INSERT INTO passagem (id_voo, cpf_cliente, num_assento, preco_pago, status)
VALUES
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 08:00:00'),
 '33333333303', '12A', 450.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 08:00:00'),
 '44444444404', '12B', 450.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 11:00:00'),
 '33333333303', '14C', 380.00, 'EMITIDA');

-- 7. LOGS DE DEMONSTRACAO
-- Registros ilustrativos; nao substituem auditoria automatica por triggers.
INSERT INTO log_auditoria
    (cpf_usuario, tabela_afetada, operacao, dados_novos)
SELECT '22222222202', 'voo', 'INSERT',
       jsonb_build_object('id_voo', v.id_voo, 'status', v.status)
FROM voo v
WHERE v.data_hora_partida = '2026-11-10 08:00:00';

INSERT INTO log_compra_passagem
    (cpf_cliente, id_voo, num_assento, resultado, mensagem)
SELECT cpf_cliente, id_voo, num_assento, 'SUCESSO',
       'Compra de demonstracao concluida.'
FROM passagem;

COMMIT;
