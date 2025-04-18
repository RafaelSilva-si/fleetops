# Use a imagem base do Node.js
FROM node:16-alpine

# Defina o diretório de trabalho dentro do contêiner
WORKDIR /usr/src/app

# Copie o package.json e o package-lock.json
COPY package*.json ./

# Instale as dependências do projeto
RUN npm install

# Copie o restante do código-fonte
COPY . .

# Compile o TypeScript
RUN npm run build

# Exponha a porta que o Express vai usar
EXPOSE 3000

# Comando para iniciar o servidor
CMD [ "npm", "run", "start" ]
