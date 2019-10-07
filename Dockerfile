#
# PHP Dependencies
#
FROM composer:1.7 as vendor

COPY database/ database/

COPY composer.json composer.json

RUN composer install \
    --no-ansi \
    --no-dev \
    --ignore-platform-reqs \
    --no-interaction \
    --no-progress \
    --no-suggest \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader

#
# Frontend
#
FROM node:8.11 as frontend

RUN mkdir -p /app/public

COPY package.json package-lock.json webpack.mix.js /app/
COPY resources/js/ /app/resources/js/
COPY resources/sass/ /app/resources/sass/

WORKDIR /app

RUN npm i && npm run prod

#
# Application
#
FROM php:7.2-apache-stretch

COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf

#COPY . /var/www/html

COPY ./app /var/www/html/app
COPY ./bootstrap /var/www/html/bootstrap
COPY ./config /var/www/html/config
#COPY ./database /var/www/html/database
COPY ./public /var/www/html/public
COPY ./resources/lang /var/www/html/resources/lang
COPY ./resources/views /var/www/html/resources/views
COPY ./routes /var/www/html/routes
COPY ./storage /var/www/html/storage
COPY ./.env.production /var/www/html/.env

RUN chown www-data:www-data /var/www/html/storage -R
RUN chown www-data:www-data /var/www/html/bootstrap -R

COPY --from=vendor /app/vendor/ /var/www/html/vendor/
COPY --from=frontend /app/public/js/ /var/www/html/public/js/
COPY --from=frontend /app/public/css/ /var/www/html/public/css/
COPY --from=frontend /app/mix-manifest.json /var/www/html/mix-manifest.json
