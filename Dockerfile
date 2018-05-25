FROM ubuntu:16.04

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
RUN mkdir /var/run/sshd
RUN mkdir /run/php

# Set the timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Basic requirements
RUN apt-get -y install curl git nano vim sudo unzip openssh-server openssl apt-utils rsyslog python-setuptools supervisor inetutils-ping postfix
RUN apt-get -y install nginx php-fpm php-mysql mysql-client php-xdebug php-dev

# Drupal requirements
RUN apt-get update
RUN apt-get -y install php-imagick php-intl php-curl php-mcrypt php-mbstring php-gd php-zip php-xml php-opcache

# Install node.js, npm, bower and gulp
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g bower && \
    npm install -g gulp-cli

# Install Redis client
RUN wget https://github.com/phpredis/phpredis/archive/master.zip -O phpredis.zip
RUN unzip -o phpredis.zip && mv phpredis-* /tmp/phpredis && cd /tmp/phpredis && phpize && ./configure && make && sudo make install

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Blackfire
RUN wget -q -O - https://packagecloud.io/gpg.key | apt-key add -
RUN echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list
RUN apt-get update
RUN apt-get install blackfire-agent
RUN apt-get install blackfire-php

# Clean up
RUN apt-get autoclean && apt-get autoremove && apt-get clean /tmp/* /var/tmp/*

WORKDIR /var/www
