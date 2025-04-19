import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({});

export const handler = async (event) => {
  console.log("Evento recebido:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const message = JSON.parse(record.body);

    const command = new PutItemCommand({
      TableName: "EventsTable",
      Item: {
        vehicleId: { S: message.vehicleId },
        type: { S: message.type },
        timestamp: { S: message.timestamp },
        location: { S: message.details.location },
        fuelLevel: { N: String(message.details.fuelLevel) },
      },
    });

    await client.send(command);
  }

  return { statusCode: 200 };
};
