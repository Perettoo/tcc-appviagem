'use strict';

// Regras de seguranca/validacao centralizadas.
// Permite ajustar custo do bcrypt via env (em maquinas lentas, baixar pra dev).

module.exports = {
  BCRYPT_COST: Number(process.env.BCRYPT_COST) || 10,
  IDADE_MINIMA: 18,
  SENHA_TAMANHO_MIN: 8,
  NOME_TAMANHO_MIN: 2,
  CPF_TAMANHO: 11,
  EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  GRUPO_NOME_TAMANHO_MIN: 3,
  MENSAGEM_TAMANHO_MIN: 1,
  MENSAGEM_TAMANHO_MAX: 2000,
  BUSCA_TAMANHO_MIN: 2,
  // Tipo de mensagem no chat: texto comum ou um pedido de carona.
  MENSAGEM_TIPO: { TEXTO: 'TEXTO', CARONA: 'CARONA' },
  // Ciclo de vida da carona. Hoje so criamos 'pendente'; os demais ficam
  // prontos para o fluxo de aceitar/concluir (implementacao futura).
  CARONA_STATUS: {
    PENDENTE: 'pendente',
    ACEITA: 'aceita',
    CONCLUIDA: 'concluida',
    CANCELADA: 'cancelada',
  },
  // Conteudo fallback gravado na mensagem do pedido (o app renderiza um card).
  CARONA_MENSAGEM_PADRAO: 'Pediu uma carona',
  // Tipos de usuario aptos a aceitar/dirigir uma carona (subconjunto do enum
  // usuario.tipo). Passageiro puro nao pode aceitar.
  CARONA_TIPOS_MOTORISTA: ['motorista', 'ambos'],
};
