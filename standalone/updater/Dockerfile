FROM ruby:2.3

# ###### створення структури папок та копіювання проекта ######-------------
RUN mkdir -p /eqa/
WORKDIR /eqa
COPY . /eqa/

run pwd

# ###### установка необхідного софта у контейнер ######------------------------
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils python-jinja2 python-yaml python-paramiko python-httplib2 python-crypto python-setuptools sshpass python-pkg-resources sshpass expect vim

# ###### налаштування ssh з"эднання, розгортання та заливка проекту ######----
# CMD ["/bin/bash"]
CMD ["/eqa/standalone/updater/setup_standalone_updater.sh"]
