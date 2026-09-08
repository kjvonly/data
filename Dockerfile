FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y && apt install -y git

WORKDIR /usr/src/app/


ENTRYPOINT [ "git",  "clone","--depth", "1", "https://github.com/kjvonly/data.git",  "/data" ]

