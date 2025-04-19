import { EventModel } from '../models/eventModel';
import { sendEventToQueue } from '../queues/sendEventToQueue';

export const createEvent = async (event: EventModel) => {
  console.log('Processando evento:', event);
  await sendEventToQueue(event);
};
