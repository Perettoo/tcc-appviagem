-- ============================================================================
-- Evolucao do modelo de caronas (equivalente SQL das migrations 20260606*).
-- MySQL. Aplicar nesta ordem; cada bloco corresponde a uma migration Sequelize.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 20260606120000-add-capacidade-to-carro
-- Capacidade total do carro (motorista incluso). Limite de passageiros = capacidade - 1.
-- Carros ja cadastrados recebem 5 (valor tipico).
-- ----------------------------------------------------------------------------
ALTER TABLE `carro`
  ADD COLUMN `capacidade` INT NULL;

UPDATE `carro` SET `capacidade` = 5 WHERE `capacidade` IS NULL;

ALTER TABLE `carro`
  MODIFY COLUMN `capacidade` INT NOT NULL DEFAULT 5;

-- ----------------------------------------------------------------------------
-- 20260606120100-add-destino-to-carona
-- Destino/observacao do anuncio do motorista. Nullable: caronas antigas nao tem destino.
-- ----------------------------------------------------------------------------
ALTER TABLE `carona`
  ADD COLUMN `destino` VARCHAR(120) NULL;

-- ----------------------------------------------------------------------------
-- 20260606120200-add-status-to-carona_usuario
-- Status do pedido do passageiro: pendente -> aprovado/recusado.
-- Vinculos antigos viram 'aprovado' (ja eram passageiros efetivos).
-- ----------------------------------------------------------------------------
ALTER TABLE `carona_usuario`
  ADD COLUMN `status` ENUM('pendente', 'aprovado', 'recusado') NOT NULL DEFAULT 'pendente';

UPDATE `carona_usuario` SET `status` = 'aprovado';

-- ----------------------------------------------------------------------------
-- 20260606120300-change-carona-status
-- Novo ciclo de vida da carona: aberta -> concluida/cancelada.
-- Migra dados: 'aceita' -> 'aberta'; 'pendente' -> 'cancelada' (invalido no novo fluxo).
-- ----------------------------------------------------------------------------
-- 1) Alarga o ENUM para conter antigos + novos, permitindo o UPDATE.
ALTER TABLE `carona`
  MODIFY COLUMN `status`
    ENUM('pendente', 'aceita', 'aberta', 'concluida', 'cancelada')
    NOT NULL DEFAULT 'aberta';

UPDATE `carona` SET `status` = 'aberta'    WHERE `status` = 'aceita';
UPDATE `carona` SET `status` = 'cancelada' WHERE `status` = 'pendente';

-- 2) Estreita o ENUM para o conjunto final.
ALTER TABLE `carona`
  MODIFY COLUMN `status`
    ENUM('aberta', 'concluida', 'cancelada')
    NOT NULL DEFAULT 'aberta';
