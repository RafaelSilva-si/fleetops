import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({});

export const handler = async (event) => {
  console.log("Evento recebido:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const message = JSON.parse(record.body);
    const messageBody = JSON.parse(message.MessageBody);

    const command = new PutItemCommand({
      TableName: "EventsTable",
      Item: {
        vehicleId: { S: messageBody.vehicleId },
        type: { S: messageBody.type },
        timestamp: { S: messageBody.timestamp },
        location: { S: messageBody.details.location },
        fuelLevel: { N: String(messageBody.details.fuelLevel) },
      },
    });

    await client.send(command);
  }

  return { statusCode: 200 };
};
