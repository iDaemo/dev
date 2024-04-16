FROM alpine:3

RUN apk update && apk add python3
COPY pynetinstall /pynetinstall

VOLUME /config
ENTRYPOINT /usr/bin/python3 -m pynetinstall -c /config/pynetinstall.ini -v 

