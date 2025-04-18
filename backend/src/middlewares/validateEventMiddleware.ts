import { Request, Response, NextFunction } from 'express';

export const validateEvent = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  const event = req.body;

  if (!event.vehicleId || !event.type) {
    res.status(400).json({
      error: 'Evento inválido. Campos "type" e "vehicleId" são obrigatórios.',
    });
    return;
  }
  next();
};
