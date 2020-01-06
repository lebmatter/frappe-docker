# Ubuntu based docker file for Frappe
# This is a Work in Progress

FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

ENV LANGUAGE=C.UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y --no-install-suggests --no-install-recommends \
    python3 python3-pip python3-setuptools python3-dev python3-wheel \
    libssl-dev  wkhtmltopdf curl git gcc g++ build-essential make \
    mysql-client redis-server

# Nodejs and yarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

RUN groupadd -r -g 1000 frappe
RUN useradd -r -m -u 1000 -g frappe frappe
ENV LIBRARY_PATH=/lib:/usr/lib
WORKDIR /home/frappe
ENV PATH="${PATH}:/home/frappe/.local/bin"


USER frappe
EXPOSE 8000

ARG FRAPPE_PATH="https://github.com/frappe/frappe.git"
ARG FRAPPE_BRANCH="develop"
ARG FRAPPE_PYTHON="python3"

RUN git clone https://github.com/frappe/bench bench-repo
RUN pip3 install --user -e bench-repo && rm -rf ~/.cache/pip
RUN export PATH=${PATH}:~/.local/bin/
RUN bench init frappe-bench --frappe-path ${FRAPPE_PATH} --frappe-branch ${FRAPPE_BRANCH}  --python ${FRAPPE_PYTHON} --no-backups --no-auto-update
