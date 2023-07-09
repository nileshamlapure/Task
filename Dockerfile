# Dockerfile for Elasticsearch

FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add a non-root user for Elasticsearch
RUN useradd -m -d /home/elasticsearch -s /bin/bash elasticsearch

# Install Elasticsearch
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
RUN apt-get update && apt-get install -y elasticsearch

# Create the logs directory and set ownership/permissions
RUN mkdir -p /var/log/elasticsearch
RUN chown -R elasticsearch:elasticsearch /var/log/elasticsearch
RUN chmod 777 /var/log/elasticsearch

# Configure Elasticsearch
COPY elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

# Change ownership of Elasticsearch files to the non-root user
RUN chown -R elasticsearch:elasticsearch /etc/elasticsearch
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
RUN chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

# Mount volume for data persistence
VOLUME /var/lib/elasticsearch

# Expose Elasticsearch ports
EXPOSE 9200 9300

# Switch to the non-root user
USER elasticsearch

# Set Elasticsearch as the entry point
ENTRYPOINT ["/usr/share/elasticsearch/bin/elasticsearch"]
