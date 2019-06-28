FROM ubuntu:latest

COPY run_forever.sh /

RUN apt update
RUN apt install -y iproute2

CMD ["/run_forever.sh"]
