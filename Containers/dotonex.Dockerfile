FROM golang:latest

# Set working directory 
WORKDIR /working

COPY . .

RUN ["./configure"]
CMD ["make"]