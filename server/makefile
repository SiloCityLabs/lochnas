build:
	go build -buildvcs=false -o ../server.bin server && \
	cd ../ && \
	chmod +x server.bin

run: 
	../server.bin

ip:
	../server.bin -ddns ip
refresh:
	../server.bin -ddns refresh
force:
	../server.bin -ddns force