// handler.ts
export const handler = async (event: any) => {
    console.log('Evento recebido:', JSON.stringify(event, null, 2));
  
    for (const record of event.Records) {
      const message = JSON.parse(record.body);
      console.log('Mensagem:', message);
    }
  
    return { statusCode: 200 };
  };
  