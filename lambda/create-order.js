const { randomUUID } = require("node:crypto");
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");

const sqsClient = new SQSClient({});

exports.handler = async (event) => {
  let body;
  try {
    body = JSON.parse(event.body || "{}");
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "El cuerpo de la solicitud debe ser JSON válido" }),
    };
  }

  if (!body.productId || body.amount == null) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Se requieren los campos productId y amount" }),
    };
  }

  const order = {
    orderId: `API-${randomUUID()}`,
    productId: body.productId,
    amount: body.amount,
  };

  try {
    await sqsClient.send(new SendMessageCommand({
      QueueUrl: process.env.QUEUE_URL,
      MessageBody: JSON.stringify(order),
    }));
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "No se pudo guardar la orden" }),
    };
  }

  return {
    statusCode: 201,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: "Orden recibida", order }),
  };
};
