# Install dependencies only when needed
FROM node:20.10.0-alpine3.18 AS deps

RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json ./
RUN yarn install --frozen-lockfile

# Build the app with cache dependencies
FROM node:20.10.0-alpine3.18 AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build


# Production image, copy all the files and run next
FROM node:20.10.0-alpine3.18 AS runner

# Set working directory
WORKDIR /usr/src/app

COPY package.json ./

RUN yarn install --prod

COPY --from=builder /app/dist ./dist

# # Copiar el directorio y su contenido
# RUN mkdir -p ./pokedex

# COPY --from=builder ./app/dist/ ./app
# COPY ./.env ./app/.env

# # Dar permiso para ejecutar la applicación
# RUN adduser --disabled-password pokeuser
# RUN chown -R pokeuser:pokeuser ./pokedex
# USER pokeuser

# EXPOSE 3000

CMD [ "node","dist/main" ]