-- Visão para o Painel do Aeroporto (Voos com trecho e status)
CREATE OR REPLACE VIEW vw_painel_voos AS
SELECT 
    v.id_voo,
    t.cidade_origem,
    t.cidade_destino,
    a.modelo AS aeronave,
    v.data_hora_partida,
    v.data_hora_chegada,
    v.status,
    v.assentos_disponiveis
FROM voo v
JOIN trajeto t ON v.id_trajeto = t.id_trajeto
JOIN aeronave a ON v.id_aeronave = a.id_aeronave;

