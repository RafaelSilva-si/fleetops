import { Router } from 'express';
import { validateEvent } from '../middlewares/validateEventMiddleware';
import { handleEvent } from '../controllers/eventsController';

const router = Router();

router.post('/', validateEvent, handleEvent);

export default router;
