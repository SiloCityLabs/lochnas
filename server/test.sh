#!/bin/bash

go build -o ../server_test.bin server && \
cd ../ && \
chmod +x server_test.bin && \
./server_test.bin -apps test
rm -f ./server_test.bin