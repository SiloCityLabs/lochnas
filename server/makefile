build:
	go build -buildvcs=false -o ../server.bin server && \
	cd ../ && \
	chmod +x server.bin

run: 
	../server.bin

test: 
	../server.bin -apps test

notify: 
	../server.bin -server notify

ip:
	../server.bin -ddns ip
refresh:
	../server.bin -ddns refresh
force:
	../server.bin -ddns force

