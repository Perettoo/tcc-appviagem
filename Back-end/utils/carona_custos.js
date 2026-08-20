'use strict';

const security = require('../config/security');

// Custos de uma viagem e o rateio entre os passageiros.
//
// O motorista informa quanto rodou (km) e quanto pagou no litro. Como nao
// guardamos o consumo de cada carro, o consumo medio (km/L) converte os km em
// litros. A taxa do app (R$/km) e somada ao combustivel e so entao o total e
// dividido pelos passageiros aprovados.

// Arredonda para centavos (evita 0.30000000000000004 no JSON).
function centavos(valor) {
  return Math.round(valor * 100) / 100;
}

// Retorna null enquanto km/valor do litro nao foram informados: sem os dois
// nao ha total de viagem.
function calcularCustos({ kmRodados, valorLitro, passageiros }) {
  if (kmRodados == null || valorLitro == null) return null;

  // DECIMAL chega como string do MySQL.
  const km = Number(kmRodados);
  const litro = Number(valorLitro);
  if (!Number.isFinite(km) || !Number.isFinite(litro)) return null;

  const litros = km / security.CARONA_CONSUMO_MEDIO_KM_L;
  const combustivel = centavos(litros * litro);
  const taxa = centavos(km * security.CARONA_TAXA_POR_KM);
  const total = centavos(combustivel + taxa);
  const qtd = Math.max(Number(passageiros) || 0, 0);

  return {
    kmRodados: km,
    valorLitro: litro,
    consumoMedio: security.CARONA_CONSUMO_MEDIO_KM_L,
    litros: centavos(litros),
    combustivel,
    taxaPorKm: security.CARONA_TAXA_POR_KM,
    taxa,
    total,
    passageiros: qtd,
    // Sem passageiro aprovado ainda nao ha como ratear.
    valorPorPassageiro: qtd > 0 ? centavos(total / qtd) : null,
  };
}

module.exports = { calcularCustos };
