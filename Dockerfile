FROM debian:7

ENV DEBIAN_FRONTEND=noninteractive

# 💀 Debian 7 is EOL — force archive repos
RUN echo "deb http://archive.debian.org/debian wheezy main contrib non-free" > /etc/apt/sources.list \
 && echo "deb-src http://archive.debian.org/debian wheezy main contrib non-free" >> /etc/apt/sources.list \
 && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until \
 && echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until \
 && echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until

# 🧹 Clean and update (DO NOT combine yet)
RUN apt-get clean
RUN apt-get update

# 📦 Install dependencies
RUN apt-get install -y --force-yes \
    apache2 \
    apache2-dev \
    build-essential \
    autoconf \
    libxml2-dev \
    wget \
    curl \
    libssl-dev \
    pkg-config

WORKDIR /usr/src

# 🐘 PHP 5.3.29
RUN wget https://museum.php.net/php5/php-5.3.29.tar.gz \
 && tar xzf php-5.3.29.tar.gz \
 && cd php-5.3.29 \
 && ./configure --with-apxs2=/usr/bin/apxs \
 && make -j$(nproc) \
 && make install

# 🐞 Xdebug 2.2.7
RUN wget https://xdebug.org/files/xdebug-2.2.7.tgz \
 && tar xzf xdebug-2.2.7.tgz \
 && cd xdebug-2.2.7 \
 && phpize \
 && ./configure --enable-xdebug \
 && make \
 && make install

# ⚙️ Xdebug config
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
