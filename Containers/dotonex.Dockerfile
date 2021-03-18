FROM golang:latest

WORKDIR /working

COPY . .

RUN ["./configure", "-cflags=''"]
RUN ["make", "dotonex", "dotonex-runner", "dotonex-compose"]
CMD ["make", "check"]
