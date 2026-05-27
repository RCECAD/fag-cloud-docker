######### BUILDER #############
# define imagem a ser utilizada pelo builder
FROM node:lts AS builder

# define path default para arquivos dentro do container
WORKDIR /usr/src/app

# copia manifests separado — aproveita cache de layers
COPY package*.json ./

# instala dependencias (garante versão com o CI)
RUN npm ci

# copia o restante do código
COPY ./aula-cloud-docker/ ./

# build do projeto gerando os arquivos estáticos em /dist
RUN npm run build


######### RUNTIME #############
# define imagem mínima para servir os arquivos em produção
FROM nginx:stable-alpine AS runtime

# copia apenas o /dist do estágio anterior — Node não vai para essa imagem
COPY --from=builder /usr/src/app/dist/ /usr/share/nginx/html/

# expõe a porta do nginx
EXPOSE 80

# mantém o nginx em foreground para o container ficar vivo
CMD ["nginx", "-g", "daemon off;"]