FROM php:7.3-cli
RUN docker-php-ext-install pdo pdo_mysql
WORKDIR /app
COPY . /app
CMD [ "php", "./bin/console", "server:run", "0.0.0.0:80" ]
