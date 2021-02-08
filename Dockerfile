# Dockerfile

FROM ruby:2.7.1

EXPOSE 4567
WORKDIR /app

RUN \
  apt-get update && \
  rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH=/bundle \
  BUNDLE_BIN=/bundle/bin \
  GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

COPY docker-entry.sh .

ENTRYPOINT ["/app/docker-entry.sh"]
CMD ["rackup", "--host", "0.0.0.0", "-p", "4567"]
