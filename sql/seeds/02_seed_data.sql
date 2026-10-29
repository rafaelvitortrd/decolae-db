ROLLBACK;

TRUNCATE TABLE 
    log_compra_passagem,
    log_auditoria,
    passagem,
    escala_tripulante_voo,
    voo,
    tripulante,
    trajeto,
    aeronave,
    cliente,
    gerente,
    admin,
    usuario
CASCADE;

INSERT INTO usuario
    (cpf, email, senha, p_nome, s_nome, telefone, data_nascimento,
     rua, numero, bairro, cidade, estado, cep, tipo_usuario)
VALUES
('11111111101', 'carlos.gerente@decolae.example', 'senha_demo_gerente_1', 'Carlos', 'Andrade', '31988887777', '1980-05-12', 'Rua das Flores', '100', 'Centro', 'Belo Horizonte', 'MG', '30100000', 'GERENTE'),
('55555555505', 'patricia.gerente@decolae.example', 'senha_demo_gerente_2', 'Patricia', 'Almeida', '31988886666', '1985-02-10', 'Rua do Comercio', '225', 'Centro', 'Contagem', 'MG', '32000000', 'GERENTE'),
('22222222202', 'mariana.admin@decolae.example', 'senha_demo_admin_1', 'Mariana', 'Silva', '31977776666', '1990-08-20', 'Avenida Paulista', '1500', 'Bela Vista', 'Sao Paulo', 'SP', '01310100', 'ADMIN'),
('66666666606', 'rodrigo.admin@decolae.example', 'senha_demo_admin_2', 'Rodrigo', 'Lima', '11977775555', '1989-06-22', 'Rua Vergueiro', '320', 'Liberdade', 'Sao Paulo', 'SP', '01504000', 'ADMIN'),
('33333333303', 'lucas.cliente@decolae.example', 'senha_demo_cliente_1', 'Lucas', 'Menezes', '32999991111', '1995-03-15', 'Rua Tiradentes', '250', 'Fabricas', 'Sao Joao del-Rei', 'MG', '36300000', 'CLIENTE'),
('44444444404', 'beatriz.cliente@decolae.example', 'senha_demo_cliente_2', 'Beatriz', 'Ferreira', '21988882222', '1998-11-28', 'Rua Barata Ribeiro', '40', 'Copacabana', 'Rio de Janeiro', 'RJ', '22040000', 'CLIENTE'),
('77777777707', 'gabriel.costa@decolae.example', 'senha_demo_cliente_3', 'Gabriel', 'Costa', '31987654321', '1992-04-10', 'Rua da Bahia', '500', 'Lourdes', 'Belo Horizonte', 'MG', '30160011', 'CLIENTE'),
('88888888808', 'larissa.moraes@decolae.example', 'senha_demo_cliente_4', 'Larissa', 'Moraes', '11981234567', '2000-01-22', 'Rua Augusta', '890', 'Consolacao', 'Sao Paulo', 'SP', '01305100', 'CLIENTE'),
('99999999909', 'felipe.siqueira@decolae.example', 'senha_demo_cliente_5', 'Felipe', 'Siqueira', '61991238888', '1988-09-05', 'SQS 304 Bloco B', '12', 'Asa Sul', 'Brasilia', 'DF', '70338020', 'CLIENTE'),
('10101010100', 'camila.duarte@decolae.example', 'senha_demo_cliente_6', 'Camila', 'Duarte', '71988883344', '1994-07-19', 'Avenida Oceanica', '300', 'Barra', 'Salvador', 'BA', '40140130', 'CLIENTE'),
('12121212111', 'thiago.rocha@decolae.example', 'senha_demo_cliente_7', 'Thiago', 'Rocha', '31998761234', '1993-12-01', 'Avenida Afonso Pena', '1200', 'Funcionarios', 'Belo Horizonte', 'MG', '30130005', 'CLIENTE'),
('13131313122', 'amanda.souza@decolae.example', 'senha_demo_cliente_8', 'Amanda', 'Souza', '21976543210', '1997-03-25', 'Rua Voluntarios da Patria', '85', 'Botafogo', 'Rio de Janeiro', 'RJ', '22270000', 'CLIENTE');

INSERT INTO gerente (cpf_gerente, matricula, departamento) VALUES
('11111111101', 'GER-001', 'Operacoes e Frota'),
('55555555505', 'GER-002', 'Planejamento de Rotas');

INSERT INTO admin (cpf_admin, matricula, turno, setor) VALUES
('22222222202', 'ADM-001', 'Matutino', 'Controle de Malha Aerea'),
('66666666606', 'ADM-002', 'Vespertino', 'Operacoes de Voo');

INSERT INTO cliente (cpf_cliente, saldo_milhas) VALUES
('33333333303', 15000),
('44444444404', 5000),
('77777777707', 22400),
('88888888808', 3500),
('99999999909', 48000),
('10101010100', 8200),
('12121212111', 12000),
('13131313122', 19500);

INSERT INTO aeronave
    (identificacao_registro, modelo, capacidade, cpf_gerente_cadastro)
VALUES
('PT-DEC', 'Airbus A320', 174, '11111111101'),
('PR-VOO', 'Boeing 737-800', 162, '11111111101'),
('PR-EXP', 'Embraer E195-E2', 136, '55555555505'),
('PS-AER', 'Airbus A321neo', 216, '55555555505');

INSERT INTO trajeto
    (cidade_origem, cidade_destino, horario_saida_padrao,
     horario_chegada_padrao, cpf_gerente_cadastro)
VALUES
('Belo Horizonte (CNF)', 'Sao Paulo (GRU)', '08:00:00', '09:15:00', '11111111101'),
('Sao Paulo (GRU)', 'Rio de Janeiro (SDU)', '11:00:00', '12:00:00', '11111111101'),
('Rio de Janeiro (SDU)', 'Belo Horizonte (CNF)', '15:00:00', '16:10:00', '55555555505'),
('Belo Horizonte (CNF)', 'Brasilia (BSB)', '13:30:00', '14:50:00', '11111111101'),
('Sao Paulo (GRU)', 'Salvador (SSA)', '17:40:00', '20:05:00', '55555555505');

INSERT INTO tripulante (nome, funcao, cpf_gerente_cadastro) VALUES
('Marcos Pereira', 'PILOTO', '11111111101'),
('Juliana Costa', 'COPILOTO', '11111111101'),
('Ricardo Neves', 'COMISSARIO', '11111111101'),
('Aline Rocha', 'COMISSARIO', '11111111101'),
('Pedro Martins', 'PILOTO', '55555555505'),
('Fernanda Oliveira', 'COPILOTO', '55555555505'),
('Caio Santos', 'COMISSARIO', '55555555505'),
('Bruna Souza', 'COMISSARIO', '55555555505');

INSERT INTO voo
    (id_trajeto, id_aeronave, cpf_admin_criador,
     data_hora_partida, data_hora_chegada, status, assentos_disponiveis)
VALUES
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Belo Horizonte (CNF)' AND cidade_destino = 'Sao Paulo (GRU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PT-DEC'),
 '22222222202', '2026-11-10 08:00:00', '2026-11-10 09:15:00', 'CONFIRMADO', 170),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Sao Paulo (GRU)' AND cidade_destino = 'Rio de Janeiro (SDU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-VOO'),
 '66666666606', '2026-11-10 11:00:00', '2026-11-10 12:00:00', 'PROGRAMADO', 158),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Rio de Janeiro (SDU)' AND cidade_destino = 'Belo Horizonte (CNF)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-EXP'),
 '22222222202', '2026-11-10 15:00:00', '2026-11-10 16:10:00', 'PROGRAMADO', 133),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Belo Horizonte (CNF)' AND cidade_destino = 'Brasilia (BSB)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PS-AER'),
 '22222222202', '2026-11-10 13:30:00', '2026-11-10 14:50:00', 'PROGRAMADO', 213),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Sao Paulo (GRU)' AND cidade_destino = 'Salvador (SSA)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PT-DEC'),
 '66666666606', '2026-11-10 17:40:00', '2026-11-10 20:05:00', 'PROGRAMADO', 171),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Belo Horizonte (CNF)' AND cidade_destino = 'Sao Paulo (GRU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PT-DEC'),
 '22222222202', '2026-11-11 08:00:00', '2026-11-11 09:15:00', 'PROGRAMADO', 171),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Sao Paulo (GRU)' AND cidade_destino = 'Rio de Janeiro (SDU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-VOO'),
 '66666666606', '2026-11-11 11:00:00', '2026-11-11 12:00:00', 'PROGRAMADO', 160),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Rio de Janeiro (SDU)' AND cidade_destino = 'Belo Horizonte (CNF)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-EXP'),
 '22222222202', '2026-11-11 15:00:00', '2026-11-11 16:10:00', 'PROGRAMADO', 133),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Sao Paulo (GRU)' AND cidade_destino = 'Rio de Janeiro (SDU)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-VOO'),
 '66666666606', '2026-11-09 11:00:00', '2026-11-09 12:00:00', 'FINALIZADO', 159),
((SELECT id_trajeto FROM trajeto WHERE cidade_origem = 'Rio de Janeiro (SDU)' AND cidade_destino = 'Belo Horizonte (CNF)'),
 (SELECT id_aeronave FROM aeronave WHERE identificacao_registro = 'PR-EXP'),
 '66666666606', '2026-11-09 15:00:00', '2026-11-09 16:10:00', 'FINALIZADO', 134);

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
    ('2026-11-10 11:00:00'::timestamp, 'Bruna Souza', 'Comissario'),
    ('2026-11-10 15:00:00'::timestamp, 'Marcos Pereira', 'Piloto'),
    ('2026-11-10 15:00:00'::timestamp, 'Juliana Costa', 'Copiloto'),
    ('2026-11-10 15:00:00'::timestamp, 'Ricardo Neves', 'Comissario'),
    ('2026-11-10 15:00:00'::timestamp, 'Aline Rocha', 'Comissario'),
    ('2026-11-10 13:30:00'::timestamp, 'Pedro Martins', 'Piloto'),
    ('2026-11-10 13:30:00'::timestamp, 'Fernanda Oliveira', 'Copiloto'),
    ('2026-11-10 13:30:00'::timestamp, 'Caio Santos', 'Comissario'),
    ('2026-11-10 13:30:00'::timestamp, 'Bruna Souza', 'Comissario'),
    ('2026-11-10 17:40:00'::timestamp, 'Marcos Pereira', 'Piloto'),
    ('2026-11-10 17:40:00'::timestamp, 'Juliana Costa', 'Copiloto'),
    ('2026-11-10 17:40:00'::timestamp, 'Ricardo Neves', 'Comissario'),
    ('2026-11-10 17:40:00'::timestamp, 'Aline Rocha', 'Comissario')
) AS dados(partida, nome, papel)
JOIN voo v ON v.data_hora_partida = dados.partida
JOIN tripulante t ON t.nome = dados.nome;

INSERT INTO passagem (id_voo, cpf_cliente, num_assento, preco_pago, status)
VALUES
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 08:00:00'), '33333333303', '12A', 450.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 08:00:00'), '44444444404', '12B', 450.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 08:00:00'), '77777777707', '14A', 480.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 08:00:00'), '88888888808', '14B', 480.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 11:00:00'), '33333333303', '03A', 380.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 11:00:00'), '44444444404', '03B', 380.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 11:00:00'), '99999999909', '05C', 350.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 11:00:00'), '10101010100', '05D', 350.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 15:00:00'), '12121212111', '01A', 410.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 15:00:00'), '13131313122', '01B', 410.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 15:00:00'), '77777777707', '02A', 410.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 13:30:00'), '88888888808', '08A', 520.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 13:30:00'), '99999999909', '08B', 520.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 13:30:00'), '10101010100', '09A', 490.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 17:40:00'), '12121212111', '15A', 610.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 17:40:00'), '13131313122', '15B', 610.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-10 17:40:00'), '33333333303', '16A', 580.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 08:00:00'), '44444444404', '04A', 470.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 08:00:00'), '77777777707', '04B', 470.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 08:00:00'), '88888888808', '05A', 450.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 11:00:00'), '99999999909', '10C', 360.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 11:00:00'), '10101010100', '10D', 360.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 15:00:00'), '12121212111', '06A', 390.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 15:00:00'), '13131313122', '06B', 390.00, 'EMITIDA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-11 15:00:00'), '33333333303', '07A', 390.00, 'EMITIDA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-09 11:00:00'), '44444444404', '02A', 380.00, 'UTILIZADA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-09 11:00:00'), '77777777707', '02B', 380.00, 'UTILIZADA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-09 11:00:00'), '88888888808', '03A', 350.00, 'UTILIZADA'),

((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-09 15:00:00'), '99999999909', '01A', 410.00, 'UTILIZADA'),
((SELECT id_voo FROM voo WHERE data_hora_partida = '2026-11-09 15:00:00'), '10101010100', '01B', 410.00, 'UTILIZADA');

INSERT INTO log_auditoria (cpf_usuario, tabela_afetada, operacao, dados_novos)
SELECT '22222222202', 'voo', 'INSERT', jsonb_build_object('id_voo', v.id_voo, 'status', v.status)
FROM voo v;

INSERT INTO log_compra_passagem (cpf_cliente, id_voo, num_assento, resultado, mensagem)
SELECT cpf_cliente, id_voo, num_assento, 'SUCESSO', 'Compra concluida com sucesso.'
FROM passagem;