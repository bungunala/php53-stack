FROM debian:7

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    apache2-dev \
    build-essential \
    autoconf \
    libxml2-dev \
    wget \
    curl \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

# PHP 5.3.29
RUN wget https://museum.php.net/php5/php-5.3.29.tar.gz \
    && tar xzf php-5.3.29.tar.gz \
    && cd php-5.3.29 \
    && ./configure --with-apxs2=/usr/bin/apxs \
    && make -j$(nproc) \
    && make install

# Xdebug 2.2.7
RUN wget https://xdebug.org/files/xdebug-2.2.7.tgz \
    && tar xzf xdebug-2.2.7.tgz \
    && cd xdebug-2.2.7 \
    && phpize \
    && ./configure --enable-xdebug \
    && make \
    && make install

# Xdebug config
RUN echo "zend_extension=xdebug.so" > /usr/local/lib/php.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/lib/php.ini \
    && echo "xdebug.remote_autostart=1" >> /usr/local/lib/php.ini \
    && echo "xdebug.remote_port=9003" >> /usr/local/lib/php.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/lib/php.ini \
    && echo "xdebug.idekey=VSCODE" >> /usr/local/lib/php.ini

RUN a2enmod php5

WORKDIR /var/www/html
EXPOSE 80 9003

CMD ["apachectl", "-D", "FOREGROUND"]
