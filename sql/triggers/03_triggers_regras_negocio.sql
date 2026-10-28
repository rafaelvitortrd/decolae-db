
-- 1. CONTROLE AUTOMÁTICO DE ASSENTOS E BLOQUEIO DE OVERBOOKING
-- Atualiza 'assentos_disponiveis' em 'voo' ao emitir ou cancelar passagens.

CREATE OR REPLACE FUNCTION fn_gerenciar_assentos_passagem()
RETURNS TRIGGER AS $$
DECLARE
    v_assentos_atuais INT;
BEGIN
    -- Ao emitir uma nova passagem
    IF (TG_OP = 'INSERT') THEN
        IF NEW.status = 'EMITIDA' THEN
            SELECT assentos_disponiveis INTO v_assentos_atuais
            FROM voo
            WHERE id_voo = NEW.id_voo
            FOR UPDATE;

            IF v_assentos_atuais <= 0 THEN
                RAISE EXCEPTION 'Operação cancelada: Voo % sem assentos disponíveis para reserva.', NEW.id_voo;
            END IF;

            UPDATE voo
            SET assentos_disponiveis = assentos_disponiveis - 1
            WHERE id_voo = NEW.id_voo;
        END IF;

    -- Ao alterar status da passagem (ex: cancelamento)
    ELSIF (TG_OP = 'UPDATE') THEN
        IF OLD.status = 'EMITIDA' AND NEW.status = 'CANCELADA' THEN
            UPDATE voo
            SET assentos_disponiveis = assentos_disponiveis + 1
            WHERE id_voo = NEW.id_voo;
        ELSIF OLD.status = 'CANCELADA' AND NEW.status = 'EMITIDA' THEN
            SELECT assentos_disponiveis INTO v_assentos_atuais
            FROM voo
            WHERE id_voo = NEW.id_voo
            FOR UPDATE;

            IF v_assentos_atuais <= 0 THEN
                RAISE EXCEPTION 'Operação cancelada: Voo % já atingiu a lotação máxima.', NEW.id_voo;
            END IF;

            UPDATE voo
            SET assentos_disponiveis = assentos_disponiveis - 1
            WHERE id_voo = NEW.id_voo;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_gerenciar_assentos ON passagem;
CREATE TRIGGER trg_gerenciar_assentos
AFTER INSERT OR UPDATE ON passagem
FOR EACH ROW
EXECUTE FUNCTION fn_gerenciar_assentos_passagem();



-- 2. PREVENÇÃO DE CONFLITO DE HORÁRIOS DA AERONAVE
-- Impede que o mesmo avião esteja alocado em voos sobrepostos no tempo.


CREATE OR REPLACE FUNCTION fn_validar_conflito_aeronave()
RETURNS TRIGGER AS $$
DECLARE
    v_conflito INT;
BEGIN
    SELECT COUNT(*) INTO v_conflito
    FROM voo
    WHERE id_aeronave = NEW.id_aeronave
      AND id_voo != COALESCE(NEW.id_voo, -1)
      AND status != 'CANCELADO'
      AND (
          (NEW.data_hora_partida, NEW.data_hora_chegada) OVERLAPS (data_hora_partida, data_hora_chegada)
      );

    IF v_conflito > 0 THEN
        RAISE EXCEPTION 'Conflito de malha aérea: Aeronave % já alocada em voo conflitante nesse intervalo.', NEW.id_aeronave;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_conflito_aeronave ON voo;
CREATE TRIGGER trg_validar_conflito_aeronave
BEFORE INSERT OR UPDATE ON voo
FOR EACH ROW
EXECUTE FUNCTION fn_validar_conflito_aeronave();



-- 3. PREVENÇÃO DE CHOQUE DE ESCALA DE TRIPULANTE
-- Impede que um tripulante seja escalado para voos com horários coincidentes.


CREATE OR REPLACE FUNCTION fn_validar_conflito_tripulante()
RETURNS TRIGGER AS $$
DECLARE
    v_partida_novo TIMESTAMP;
    v_chegada_novo TIMESTAMP;
    v_conflito INT;
BEGIN
    SELECT data_hora_partida, data_hora_chegada
    INTO v_partida_novo, v_chegada_novo
    FROM voo
    WHERE id_voo = NEW.id_voo;

    SELECT COUNT(*) INTO v_conflito
    FROM escala_tripulante_voo e
    JOIN voo v ON e.id_voo = v.id_voo
    WHERE e.id_tripulante = NEW.id_tripulante
      AND e.id_voo != NEW.id_voo
      AND v.status != 'CANCELADO'
      AND (
          (v_partida_novo, v_chegada_novo) OVERLAPS (v.data_hora_partida, v.data_hora_chegada)
      );

    IF v_conflito > 0 THEN
        RAISE EXCEPTION 'Conflito de escala: Tripulante % já possui voo agendado nesse intervalo.', NEW.id_tripulante;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_conflito_tripulante ON escala_tripulante_voo;
CREATE TRIGGER trg_validar_conflito_tripulante
BEFORE INSERT OR UPDATE ON escala_tripulante_voo
FOR EACH ROW
EXECUTE FUNCTION fn_validar_conflito_tripulante();



-- 4. VALIDAÇÃO DE TRIPULAÇÃO MÍNIMA AO CONFIRMAR VOO
-- Exige pelo menos 1 Piloto, 1 Copiloto e 2 Comissários para confirmar o voo.


CREATE OR REPLACE FUNCTION fn_validar_tripulacao_minima()
RETURNS TRIGGER AS $$
DECLARE
    v_qtd_piloto INT;
    v_qtd_copiloto INT;
    v_qtd_comissario INT;
BEGIN
    IF NEW.status = 'CONFIRMADO' AND (OLD.status IS NULL OR OLD.status != 'CONFIRMADO') THEN
        SELECT 
            COUNT(*) FILTER (WHERE t.funcao = 'PILOTO'),
            COUNT(*) FILTER (WHERE t.funcao = 'COPILOTO'),
            COUNT(*) FILTER (WHERE t.funcao = 'COMISSARIO')
        INTO 
            v_qtd_piloto,
            v_qtd_copiloto,
            v_qtd_comissario
        FROM escala_tripulante_voo e
        JOIN tripulante t ON e.id_tripulante = t.id_tripulante
        WHERE e.id_voo = NEW.id_voo;

        IF v_qtd_piloto < 1 OR v_qtd_copiloto < 1 OR v_qtd_comissario < 2 THEN
            RAISE EXCEPTION 'Voo % não pode ser confirmado. Tripulação mínima incompleta (Pilotos: %, Copilotos: %, Comissários: %). Exige-se min 1/1/2.',
                NEW.id_voo, v_qtd_piloto, v_qtd_copiloto, v_qtd_comissario;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_tripulacao_minima ON voo;
CREATE TRIGGER trg_validar_tripulacao_minima
BEFORE UPDATE ON voo
FOR EACH ROW
EXECUTE FUNCTION fn_validar_tripulacao_minima();