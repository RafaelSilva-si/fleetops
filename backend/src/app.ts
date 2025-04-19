import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response } from 'express';
import bodyParser from 'body-parser';
import eventsRoute from './routes/eventsRoute';

const app = express();

const port = 3000;

app.use(bodyParser.json());

app.use('/events', eventsRoute);

app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ message: 'API está funcionando!' });
});

app.listen(port, () => {
  console.log(`Servidor rodando na http://localhost:${port}`);
});
