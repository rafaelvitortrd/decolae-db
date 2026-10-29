-- Triggers e regras de negocio 

BEGIN;


ALTER TABLE passagem DROP CONSTRAINT IF EXISTS uq_voo_assento;
CREATE UNIQUE INDEX IF NOT EXISTS uq_voo_assento_ativo
    ON passagem (id_voo, num_assento)
    WHERE status IN ('EMITIDA', 'UTILIZADA');

-- 1. ASSENTOS: BAIXA NA EMISSAO, REPOSICAO NO CANCELAMENTO
CREATE OR REPLACE FUNCTION fn_gerenciar_assentos_passagem()
RETURNS TRIGGER AS $$
DECLARE
    v_diminuir BOOLEAN := FALSE;
    v_aumentar BOOLEAN := FALSE;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_diminuir := (NEW.status = 'EMITIDA');
    ELSIF TG_OP = 'UPDATE' THEN

        IF NEW.id_voo IS DISTINCT FROM OLD.id_voo THEN
            RAISE EXCEPTION 'Nao e permitido trocar o voo de uma passagem existente.';
        END IF;
        IF (OLD.status = 'UTILIZADA' AND NEW.status = 'CANCELADA')
           OR (OLD.status = 'CANCELADA' AND NEW.status = 'UTILIZADA') THEN
            RAISE EXCEPTION 'Transicao de status de passagem nao permitida: % -> %.',
                OLD.status, NEW.status;
        END IF;
        v_diminuir := (OLD.status = 'CANCELADA' AND NEW.status = 'EMITIDA');
        v_aumentar := (OLD.status = 'EMITIDA' AND NEW.status = 'CANCELADA');
    END IF;

    IF v_diminuir THEN

        UPDATE voo
           SET assentos_disponiveis = assentos_disponiveis - 1
         WHERE id_voo = NEW.id_voo
           AND assentos_disponiveis > 0;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Voo % sem assentos disponiveis.', NEW.id_voo;
        END IF;

    ELSIF v_aumentar THEN
        UPDATE voo v
           SET assentos_disponiveis = v.assentos_disponiveis + 1
          FROM aeronave a
         WHERE v.id_voo = NEW.id_voo
           AND a.id_aeronave = v.id_aeronave
           AND v.assentos_disponiveis < a.capacidade;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Inconsistencia de capacidade no voo %.', NEW.id_voo;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_gerenciar_assentos ON passagem;
CREATE TRIGGER trg_gerenciar_assentos
AFTER INSERT OR UPDATE ON passagem
FOR EACH ROW EXECUTE FUNCTION fn_gerenciar_assentos_passagem();

-- 2. IMPEDIR DOIS VOOS ATIVOS SIMULTANEOS COM A MESMA AERONAVE
CREATE OR REPLACE FUNCTION fn_validar_conflito_aeronave()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'CANCELADO' THEN
        RETURN NEW;
    END IF;


    PERFORM 1 FROM aeronave
     WHERE id_aeronave = NEW.id_aeronave FOR UPDATE;

    IF EXISTS (
        SELECT 1 FROM voo v
         WHERE v.id_aeronave = NEW.id_aeronave
           AND v.id_voo <> COALESCE(NEW.id_voo, -1)
           AND v.status <> 'CANCELADO'
           AND (NEW.data_hora_partida, NEW.data_hora_chegada)
               OVERLAPS (v.data_hora_partida, v.data_hora_chegada)
    ) THEN
        RAISE EXCEPTION 'Aeronave % ocupada no intervalo informado.', NEW.id_aeronave;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_conflito_aeronave ON voo;
CREATE TRIGGER trg_validar_conflito_aeronave
BEFORE INSERT OR UPDATE OF id_aeronave, data_hora_partida, data_hora_chegada, status
ON voo FOR EACH ROW EXECUTE FUNCTION fn_validar_conflito_aeronave();

-- 3. IMPEDIR CONFLITO DE ESCALA E EXIGIR DESCANSO DE 36 HORAS
CREATE OR REPLACE FUNCTION fn_validar_conflito_tripulante()
RETURNS TRIGGER AS $$
DECLARE
    v_partida TIMESTAMP;
    v_chegada TIMESTAMP;
    v_status VARCHAR(30);
BEGIN
    SELECT data_hora_partida, data_hora_chegada, status
      INTO v_partida, v_chegada, v_status
      FROM voo WHERE id_voo = NEW.id_voo;

    IF v_status = 'CANCELADO' THEN
        RETURN NEW;
    END IF;


    PERFORM 1 FROM tripulante
     WHERE id_tripulante = NEW.id_tripulante FOR UPDATE;

    IF EXISTS (
        SELECT 1
          FROM escala_tripulante_voo e
          JOIN voo v ON v.id_voo = e.id_voo
         WHERE e.id_tripulante = NEW.id_tripulante
           AND e.id_voo <> NEW.id_voo
           AND v.status <> 'CANCELADO'
           AND v_partida < v.data_hora_chegada + INTERVAL '36 hours'
           AND v.data_hora_partida < v_chegada + INTERVAL '36 hours'
    ) THEN
        RAISE EXCEPTION 'Tripulante % em conflito de escala ou descanso inferior a 36 horas.',
            NEW.id_tripulante;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_conflito_tripulante ON escala_tripulante_voo;
CREATE TRIGGER trg_validar_conflito_tripulante
BEFORE INSERT OR UPDATE ON escala_tripulante_voo
FOR EACH ROW EXECUTE FUNCTION fn_validar_conflito_tripulante();

-- 4. EXIGIR 1 PILOTO, 1 COPILOTO E 2 COMISSARIOS PARA CONFIRMAR
CREATE OR REPLACE FUNCTION fn_validar_tripulacao_minima()
RETURNS TRIGGER AS $$
DECLARE
    v_pilotos BIGINT;
    v_copilotos BIGINT;
    v_comissarios BIGINT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'CONFIRMADO' THEN
            RAISE EXCEPTION 'Crie o voo como PROGRAMADO, escale a equipe e depois confirme.';
        END IF;
        RETURN NEW;
    END IF;

    IF NEW.status = 'CONFIRMADO' AND OLD.status IS DISTINCT FROM 'CONFIRMADO' THEN
        SELECT COUNT(*) FILTER (WHERE t.funcao = 'PILOTO'),
               COUNT(*) FILTER (WHERE t.funcao = 'COPILOTO'),
               COUNT(*) FILTER (WHERE t.funcao = 'COMISSARIO')
          INTO v_pilotos, v_copilotos, v_comissarios
          FROM escala_tripulante_voo e
          JOIN tripulante t ON t.id_tripulante = e.id_tripulante
         WHERE e.id_voo = NEW.id_voo;

        IF v_pilotos < 1 OR v_copilotos < 1 OR v_comissarios < 2 THEN
            RAISE EXCEPTION 'Voo %: tripulacao insuficiente (pilotos %, copilotos %, comissarios %).',
                NEW.id_voo, v_pilotos, v_copilotos, v_comissarios;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_tripulacao_minima ON voo;
CREATE TRIGGER trg_validar_tripulacao_minima
BEFORE INSERT OR UPDATE OF status ON voo
FOR EACH ROW EXECUTE FUNCTION fn_validar_tripulacao_minima();

-- 5. NAO DEIXAR VOO CONFIRMADO PERDER TRIPULACAO OBRIGATORIA
CREATE OR REPLACE FUNCTION fn_proteger_tripulacao_confirmada()
RETURNS TRIGGER AS $$
DECLARE
    v_pilotos BIGINT;
    v_copilotos BIGINT;
    v_comissarios BIGINT;
BEGIN
    IF EXISTS (SELECT 1 FROM voo WHERE id_voo = OLD.id_voo AND status = 'CONFIRMADO') THEN
        SELECT COUNT(*) FILTER (WHERE t.funcao = 'PILOTO'),
               COUNT(*) FILTER (WHERE t.funcao = 'COPILOTO'),
               COUNT(*) FILTER (WHERE t.funcao = 'COMISSARIO')
          INTO v_pilotos, v_copilotos, v_comissarios
          FROM escala_tripulante_voo e
          JOIN tripulante t ON t.id_tripulante = e.id_tripulante
         WHERE e.id_voo = OLD.id_voo;

        IF v_pilotos < 1 OR v_copilotos < 1 OR v_comissarios < 2 THEN
            RAISE EXCEPTION 'Nao e permitido deixar o voo confirmado % com equipe incompleta.',
                OLD.id_voo;
        END IF;
    END IF;
    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_proteger_tripulacao_confirmada ON escala_tripulante_voo;
CREATE TRIGGER trg_proteger_tripulacao_confirmada
AFTER DELETE OR UPDATE OF id_voo, id_tripulante ON escala_tripulante_voo
FOR EACH ROW EXECUTE FUNCTION fn_proteger_tripulacao_confirmada();

-- 6. REVALIDAR DESCANSO SE O HORARIO DO VOO FOR ALTERADO
CREATE OR REPLACE FUNCTION fn_revalidar_escala_voo()
RETURNS TRIGGER AS $$
DECLARE
    v_id_tripulante INT;
BEGIN
    IF NEW.status = 'CANCELADO' THEN
        RETURN NULL;
    END IF;

    FOR v_id_tripulante IN
        SELECT id_tripulante FROM escala_tripulante_voo
         WHERE id_voo = NEW.id_voo ORDER BY id_tripulante
    LOOP
        PERFORM 1 FROM tripulante
         WHERE id_tripulante = v_id_tripulante FOR UPDATE;

        IF EXISTS (
            SELECT 1
              FROM escala_tripulante_voo e
              JOIN voo v ON v.id_voo = e.id_voo
             WHERE e.id_tripulante = v_id_tripulante
               AND e.id_voo <> NEW.id_voo
               AND v.status <> 'CANCELADO'
               AND NEW.data_hora_partida < v.data_hora_chegada + INTERVAL '36 hours'
               AND v.data_hora_partida < NEW.data_hora_chegada + INTERVAL '36 hours'
        ) THEN
            RAISE EXCEPTION 'Alteracao do voo % gera conflito de descanso para tripulante %.',
                NEW.id_voo, v_id_tripulante;
        END IF;
    END LOOP;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_revalidar_escala_voo ON voo;
CREATE TRIGGER trg_revalidar_escala_voo
AFTER UPDATE OF data_hora_partida, data_hora_chegada, status ON voo
FOR EACH ROW EXECUTE FUNCTION fn_revalidar_escala_voo();

COMMIT;


