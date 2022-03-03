FROM ghcr.io/buildsi/libabigail:2.0
RUN apt-get update && apt-get install -y python3 python3-pip
WORKDIR /code
COPY entrypoint.sh /code/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/code/entrypoint.sh"]
