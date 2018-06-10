FROM node:9
MAINTAINER Federico Cargnelutti <fedecarg@gmail.com>

ARG PORT
ARG ENVIRONMENT

ENV PORT $PORT
ENV NODE_ENV $ENVIRONMENT

RUN mkdir -p /usr/app
WORKDIR /usr/app
RUN cd /usr/app
ADD . .

RUN npm install
RUN /bin/bash -c '[[ "${NODE_ENV}" == "production" ]] && npm run build:prod || npm run build:dev'

EXPOSE $PORT

CMD ["npm", "run", "start"]
