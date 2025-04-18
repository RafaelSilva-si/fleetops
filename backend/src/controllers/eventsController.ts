import { Request, Response } from 'express';
import { EventModel } from '../models/eventModel';
import { createEvent } from '../services/eventsService';

export const handleEvent = async (req: Request, res: Response) => {
  const event: EventModel = req.body;

  try {
    await createEvent(event);
    res.status(200).json({ message: 'Evento processado com sucesso' });
  } catch (error) {
    res.status(500).json({ error: `Erro ao processar o evento: ${error}` });
  }
};
