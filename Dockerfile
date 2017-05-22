FROM ubuntu:xenial
MAINTAINER romeOz <serggalka@gmail.com>

RUN	apt-get -qq update && apt-get -qq install wget mysql-client libmysqlclient20 libexpat1 unixodbc libpq5 locales \
	&& rm -rf /var/lib/apt/lists/* 

ENV OS_LOCALE="en_US.UTF-8" \
    OS_LANGUAGE="en_US:en" \
	SPHINX_LOG_DIR=/var/log/sphinxsearch \
	SPHINX_CONF=/etc/sphinxsearch/sphinx.conf \
	SPHINX_RUN=/run/sphinxsearch/searchd.pid \
	SPHINX_DATA_DIR=/var/lib/sphinxsearch/data \
	SPHINX_DEB="http://sphinxsearch.com/files/sphinxsearch_2.2.11-release-1~xenial_amd64.deb"

# Set the locale
RUN locale-gen ${OS_LOCALE}  ru_RU.UTF-8
ENV LANG=${OS_LOCALE} \
	LANGUAGE=${OS_LANGUAGE} \
	LC_ALL=${OS_LOCALE}

RUN wget -q "${SPHINX_DEB}" -O /tmp/sphinxsearch.deb \
	&& dpkg -i /tmp/sphinxsearch.deb \
	&& rm -f  /tmp/sphinxsearch.deb

#COPY ./configs/* /etc/sphinxsearch/
COPY ./entrypoint.sh /sbin/entrypoint.sh

RUN	ln -sf /dev/stdout ${SPHINX_LOG_DIR}/searchd.log \
	&& ln -sf /dev/stdout ${SPHINX_LOG_DIR}/query.log


RUN ln -fs /usr/share/zoneinfo/${TIMEZONE:-Europe/Moscow} /etc/localtime

EXPOSE 9312 9306
VOLUME ["${SPHINX_DATA_DIR}", "/etc/sphinxsearch"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
