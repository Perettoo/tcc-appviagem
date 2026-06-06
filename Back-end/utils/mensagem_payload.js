'use strict';

// Formato unico de mensagem usado pelo REST e pelo broadcast do socket, tanto
// para texto quanto para pedido de carona, pra que o app tenha um parser so.

function caronaPayload(carona) {
  if (!carona) return null;
  return {
    idCarona: carona.idCarona,
    status: carona.status,
    idMotorista: carona.idMotorista,
    motoristaNome: carona.motorista ? carona.motorista.nome : null,
    data: carona.data,
  };
}

function montarPayload(msg) {
  return {
    idMensagem: msg.idMensagem,
    idGrupo: msg.idGrupo,
    idAutor: msg.idUsuario,
    autorNome: msg.autor ? msg.autor.nome : null,
    conteudo: msg.conteudo,
    dataEnvio: msg.dataEnvio,
    tipo: msg.tipo,
    carona: caronaPayload(msg.carona),
  };
}

// Include reaproveitado nas consultas que devolvem mensagens completas.
function includeMensagem(db) {
  return [
    { model: db.Usuario, as: 'autor', attributes: ['idUsuario', 'nome'] },
    {
      model: db.Carona,
      as: 'carona',
      include: [
        { model: db.Usuario, as: 'motorista', attributes: ['idUsuario', 'nome'] },
      ],
    },
  ];
}

module.exports = { montarPayload, includeMensagem, caronaPayload };
