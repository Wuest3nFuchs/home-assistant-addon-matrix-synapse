FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    SYNAPSE_VERSION=1.83.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    zlib1g-dev \
    libffi-dev \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "matrix-synapse==${SYNAPSE_VERSION}"

RUN useradd -m -d /synapse -s /bin/false synapse
WORKDIR /synapse
RUN mkdir -p /data /config
RUN chown -R synapse:synapse /data /config

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

USER synapse
VOLUME ["/data", "/config"]

EXPOSE 8008 8448

CMD ["/usr/local/bin/run.sh"]

