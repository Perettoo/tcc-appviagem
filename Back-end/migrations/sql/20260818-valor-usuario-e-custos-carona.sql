-- ============================================================================
-- Saldo do usuario e custos da viagem (rateio da carona).
-- MySQL. Aplicar nesta ordem; cada bloco corresponde a uma etapa do modelo.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- usuario.valor
-- Saldo em reais. Nao ha transacao bancaria: o proprio usuario informa o valor
-- na tela Inicio. Contas ja existentes comecam zeradas.
-- DECIMAL (nao FLOAT) para nao perder centavo em arredondamento.
-- ----------------------------------------------------------------------------
ALTER TABLE `usuario`
  ADD COLUMN `valor` DECIMAL(10, 2) NOT NULL DEFAULT 0.00;

-- ----------------------------------------------------------------------------
-- carona.kmRodados / carona.valorLitro
-- Custos informados pelo motorista: quantos km rodou na viagem e quanto pagou
-- no litro ao abastecer. Sao a base do rateio:
--   combustivel = (kmRodados / consumo medio km/L) * valorLitro
--   taxa        = kmRodados * taxa por km
--   total       = combustivel + taxa, dividido pelos passageiros aprovados
-- (consumo medio e taxa por km ficam em config/security.js, nao no banco).
-- Nullable: so sao preenchidos durante a viagem, e as caronas ja existentes
-- nao tem esses dados.
-- ----------------------------------------------------------------------------
ALTER TABLE `carona`
  ADD COLUMN `kmRodados`  DECIMAL(8, 2) NULL,
  ADD COLUMN `valorLitro` DECIMAL(6, 2) NULL;

-- ----------------------------------------------------------------------------
-- Rollback (executar de tras para frente, apenas se precisar desfazer).
-- ----------------------------------------------------------------------------
-- ALTER TABLE `carona` DROP COLUMN `valorLitro`, DROP COLUMN `kmRodados`;
-- ALTER TABLE `usuario` DROP COLUMN `valor`;
