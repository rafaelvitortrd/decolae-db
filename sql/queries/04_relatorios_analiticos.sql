
-- CONSULTAS ANALÍTICAS E RELATÓRIOS OPERACIONAIS

-- 1. TAXA DE OCUPAÇÃO E RECEITA TOTAL POR VOO
-- Calcula a percentagem de ocupação e o faturamento bruto obtido por cada voo.
SELECT 
    v.id_voo,
    t.cidade_origem || ' -> ' || t.cidade_destino AS rota,
    a.modelo AS modelo_aeronave,
    a.capacidade,
    (a.capacidade - v.assentos_disponiveis) AS assentos_ocupados,
    ROUND(((a.capacidade - v.assentos_disponiveis)::NUMERIC / a.capacidade) * 100, 2) AS taxa_ocupacao_percent,
    COALESCE(SUM(p.preco_pago) FILTER (WHERE p.status = 'EMITIDA'), 0.00) AS faturamento_total
FROM voo v
JOIN trajeto t ON v.id_trajeto = t.id_trajeto
JOIN aeronave a ON v.id_aeronave = a.id_aeronave
LEFT JOIN passagem p ON v.id_voo = p.id_voo
GROUP BY v.id_voo, t.cidade_origem, t.cidade_destino, a.modelo, a.capacidade, v.assentos_disponiveis
ORDER BY faturamento_total DESC;


-- 2. ROTAS MAIS LUCRATIVAS (FATURAMENTO POR TRECHO)
-- Identifica as rotas com maior volume financeiro e total de bilhetes emitidos.
SELECT 
    t.cidade_origem,
    t.cidade_destino,
    COUNT(p.id_passagem) AS total_passagens_vendidas,
    COALESCE(SUM(p.preco_pago), 0.00) AS receita_rota,
    ROUND(AVG(p.preco_pago), 2) AS preco_medio_bilhete
FROM trajeto t
JOIN voo v ON t.id_trajeto = v.id_trajeto
LEFT JOIN passagem p ON v.id_voo = p.id_voo AND p.status = 'EMITIDA'
GROUP BY t.id_trajeto, t.cidade_origem, t.cidade_destino
ORDER BY receita_rota DESC;


-- 3. HISTÓRICO E HORAS DE VOO POR TRIPULANTE
-- Mapeia a carga operacional dos tripulantes somando a duração dos voos confirmados/finalizados.
SELECT 
    tr.id_tripulante,
    tr.nome AS nome_tripulante,
    tr.funcao,
    COUNT(e.id_voo) AS total_voos_escalados,
    COALESCE(SUM(v.data_hora_chegada - v.data_hora_partida), INTERVAL '0 hour') AS total_horas_em_voo
FROM tripulante tr
LEFT JOIN escala_tripulante_voo e ON tr.id_tripulante = e.id_tripulante
LEFT JOIN voo v ON e.id_voo = v.id_voo AND v.status != 'CANCELADO'
GROUP BY tr.id_tripulante, tr.nome, tr.funcao
ORDER BY total_horas_em_voo DESC;


-- 4. RANKING DE CLIENTES (FIDELIDADE E CONSUMO)
-- Lista os clientes mais ativos pelo saldo de milhas e gastos totais com bilhetes.
SELECT 
    u.cpf,
    u.p_nome || ' ' || u.s_nome AS nome_cliente,
    u.email,
    c.saldo_milhas,
    COUNT(p.id_passagem) AS total_compras,
    COALESCE(SUM(p.preco_pago), 0.00) AS total_gasto
FROM cliente c
JOIN usuario u ON c.cpf_cliente = u.cpf
LEFT JOIN passagem p ON c.cpf_cliente = p.cpf_cliente AND p.status = 'EMITIDA'
GROUP BY u.cpf, u.p_nome, u.s_nome, u.email, c.saldo_milhas
ORDER BY total_gasto DESC, c.saldo_milhas DESC;


-- 5. RELATÓRIO DE AUDITORIA: MONITORAMENTO DE ERROS E CONCORRÊNCIA
-- Exibe tentativas de compra que falharam por indisponibilidade de assento ou conflito.
SELECT 
    id_tentativa,
    cpf_cliente,
    id_voo,
    num_assento,
    resultado,
    mensagem,
    data_hora
FROM log_compra_passagem
WHERE resultado != 'SUCESSO'
ORDER BY data_hora DESC;