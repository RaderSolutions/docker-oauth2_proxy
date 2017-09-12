FROM buildpack-deps:jessie-curl

ENV oauth2Project=/bitly/oauth2_proxy

# this group of ENV variables are backup in case the parsing doesnt work
# we will also hard-code these when creating a historical branch
ENV OAUTH2_PROXY_BRANCH=v2.1
ENV OAUTH2_PROXY_VERSION=2.1
ENV GOLANG_VERSION=1.6
ENV ARCHIVE=$oauth2Project/releases/download/$OAUTH2_PROXY_BRANCH/oauth2_proxy-$OAUTH2_PROXY_VERSION.linux-amd64.go$GOLANG_VERSION.tar.gz

ENV PATH /opt/oauth2-proxy/bin:$PATH

RUN newArchive=`wget https://github.com$oauth2Project/releases/ -q -O - | grep -m 1 "linux-amd64" | awk '{ print $2 }' | cut -d\" -f 2` && if test "${newArchive#*"release"}" != "$newArchive" ; then export ARCHIVE=$newArchive ; echo "ARCHIVE set to most-current oauth2_proxy release" ; else export newArchive=$newArchive ; echo "ARCHIVE variable hardcoded because dynamic method failed" ; fi 

ENV tarPath=https://github.com$ARCHIVE

RUN echo "Downloading $tarPath" ; mkdir -p /opt/oauth2-proxy/bin && mkdir /opt/oauth2-proxy/etc && \
    curl -L -k --silent \
      $tarPath  | \
      tar xz --strip-components 1 -C /opt/oauth2-proxy/bin

CMD oauth2_proxy -config=/opt/oauth2-proxy/etc/config

