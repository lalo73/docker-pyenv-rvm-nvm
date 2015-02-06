# Dockerfile used to build base image for projects using Python, Node, and Ruby.
FROM ubuntu:14.04
MAINTAINER Tim Zenderman <tim@bananadesk.com>
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

WORKDIR /code

ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:/code/.nvm/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH


# Install base system libraries.
ENV DEBIAN_FRONTEND=noninteractive
COPY base_dependencies.txt /code/base_dependencies.txt
RUN apt-get update && \
    apt-get install -y $(cat /code/base_dependencies.txt)


# Install pyenv and default python version.
ENV PYTHONDONTWRITEBYTECODE true
COPY .python-version /code/.python-version
RUN git clone git://github.com/yyuu/pyenv.git /root/.pyenv && \
    cd /root/.pyenv && \
    git checkout `git describe --abbrev=0 --tags` && \
    pyenv install .python-version && \
    pyenv global $(cat .python-version)


# Install nvm and default node version.
COPY .nvmrc /code/.nvmrc
RUN git clone https://github.com/creationix/nvm.git /code/.nvm && \
    cd /code/.nvm && \
    git checkout `git describe --abbrev=0 --tags` && \
    echo 'source /code/.nvm/nvm.sh' >> /etc/profile && \
    /bin/bash -l -c "nvm install;" \
    "nvm use;"


# Install rvm, default ruby version and bundler.
COPY .ruby-version /code/.ruby-version
COPY .gemrc /code/.gemrc
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements;"
RUN rvm install $(cat .ruby-version) && \
    rvm use --default && \
    /bin/bash -l -c "gem install bundler"

CMD ["/bin/bash"]