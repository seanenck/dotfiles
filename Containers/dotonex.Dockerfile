FROM golang:latest

WORKDIR /working

COPY . .

RUN ["./configure", "-cflags=''"]
CMD ["make", "dotonex", "dotonex-runner", "dotonex-compose", "check"]
