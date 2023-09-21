FROM node:lts-alpine as deps
WORKDIR /opt
RUN apk update && \
  apk add git && \
  git clone --depth=1 https://github.com/kisakimana/notion-new.git && \
  cd nextjs-notion-starter-kit && \
  yarn install --frozen-lockfile && \
  yarn add @waline/client && \
  yarn add sass

FROM node:lts-alpine as builder
ENV NODE_ENV=production
WORKDIR /opt/app
COPY --from=deps /opt/nextjs-notion-starter-kit/ ./
COPY overrides/ ./
RUN --mount=type=secret,id=REDIS_HOST \
  --mount=type=secret,id=REDIS_PASSWORD \
  export REDIS_HOST=$(cat /run/secrets/REDIS_HOST) && \
  export REDIS_PASSWORD=$(cat /run/secrets/REDIS_PASSWORD) && \
  yarn build

FROM node:lts-alpine as runner
ENV NODE_ENV=production
WORKDIR /opt/app
COPY --from=builder /opt/app/ ./
EXPOSE 3000
CMD [ "yarn", "start" ]
