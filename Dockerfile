FROM node:21-alpine AS base
RUN apk add curl
RUN corepack enable pnpm
WORKDIR /app

COPY package.json pnpm-lock.yaml ./

FROM base as prod-deps
RUN pnpm install --production

FROM base as build-deps
RUN pnpm install --production=false

FROM build-deps as build
COPY . .
RUN pnpm run build


FROM base as runtime
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000
CMD ["node", "./dist/server/entry.mjs"]



#CMD pnpm run start

#FROM nginx:alpine AS runtime
#COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
#COPY --from=build /app/dist /usr/share/nginx/html
#EXPOSE 3000 

