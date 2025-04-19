import { SendMessageCommand } from '@aws-sdk/client-sqs';
import { sqsClient } from './sqsClient';
import { EventModel } from '../models/eventModel';

const QUEUE_URL = process.env.SQS_QUEUE_URL!;

export const sendEventToQueue = async (event: EventModel) => {
  const command = new SendMessageCommand({
    QueueUrl: QUEUE_URL,
    MessageBody: JSON.stringify(event),
  });

  await sqsClient.send(command);
};
