FROM ubuntu:16.04

MAINTAINER uzzal, uzzal2k5@gmail.com

# Install required packages and remove the apt packages cache when done.

RUN apt-get update && \
    apt-get install -y locales

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y openssl net-tools \
    libssl-dev \
    net-tools \
	nginx
	# Set the locale

RUN apt-get install -y  libssl-dev libffi-dev python3-dev
RUN apt update
RUN apt-get install -y mysql-client libmysqlclient-dev

# REQUIRED PACKAGES INSTALL
COPY req/requirements.txt /
RUN chmod a+x /requirements.txt

# CONFIG STANDARD ERROR LOG
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /etc/ssl/webcert
COPY ssl/* /etc/ssl/webcert/
COPY config/webconfig  /etc/nginx/sites-available/
RUN ln -sf /etc/nginx/sites-available/webconfig /etc/nginx/sites-enabled/webconfig

# ADJUST  PYTHON
RUN ln -sf /usr/bin/python3    /usr/bin/python

# MODIFY NGINX TO PREVENT DISPLAY NGINX VERSION
RUN sed -i 's/# server_tokens off/server_tokens off/g' /etc/nginx/nginx.conf

# INSTALL & UPDATE PIP3
RUN apt-get -y install curl && curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python3 get-pip.py
RUN python3 -m pip install --upgrade pip

# Python Virtual Environment
RUN pip3 install virtualenv
RUN virtualenv shunienv
RUN  /bin/bash -c "source shunienv/bin/activate"  \
 && apt-get install -y gcc && pip3 install -r /requirements.txt

# REMOVE NGINX DEFAULT CONFIG FILE
RUN rm -rf /etc/nginx/site-available/default

# EXPOSING PORTS & ENDPOINT
EXPOSE 80 443

STOPSIGNAL SIGTERM

ENTRYPOINT ["nginx", "-g", "daemon off;"]




