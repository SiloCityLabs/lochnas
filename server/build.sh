#!/bin/bash

go build -o ../server.bin server && \
cd ../ && \
chmod +x server.bin && \
./server.bin