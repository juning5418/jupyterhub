#FROM jdocker/jupyterhub-base:v1
#MAINTAINER JupyterFH Project <691092674@qq.com>



FROM debian:jessie
MAINTAINER JupyterFH Project <691092674@qq.com>

# install nodejs, utf8 locale, set CDN because default httpredir is unreliable
ENV DEBIAN_FRONTEND noninteractive
RUN REPO=http://cdn-fastly.deb.debian.org && \
echo "deb $REPO/debian jessie main\ndeb $REPO/debian-security jessie/updates main" > /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install wget locales git bzip2 &&\
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    locale-gen C.UTF-8 && \
    apt-get remove -y locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8

# install Python + NodeJS with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo 'd0c7c71cc5659e54ab51f2005a8d96f3 */tmp/miniconda.sh' | md5sum -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/  && \
    /opt/conda/bin/conda config --set show_channel_urls yes && \
    /opt/conda/bin/conda install --yes -c conda-forge \
      python=3.5 sqlalchemy tornado jinja2 traitlets requests pip pycurl \
      nodejs configurable-http-proxy && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH


# 添加测试用户admin，密码admin
RUN useradd admin
RUN echo "admin:admin" | chpasswd
RUN mkdir -p /home/admin
RUN chown  -R  admin:users /home/admin/


ADD . /src/jupyterhub
WORKDIR /src/jupyterhub


#RUN pip install -r dev-requirements.txt -e .
#RUN python setup.py develop

#RUN npm install --unsafe-perm
#RUN python setup.py js
#RUN python setup.py css

#RUN python setup.py build
#RUN python setup.py install

#RUN pip install .




RUN npm install --unsafe-perm && \
    pip install . && \
    rm -rf $PWD ~/.cache ~/.npm

RUN pip install notebook

RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
EXPOSE 8000

LABEL org.jupyter.service="jupyterhub"

CMD ["jupyterhub"]
