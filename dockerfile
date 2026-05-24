FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter analyze || true

RUN flutter test || true

CMD ["bash"]
