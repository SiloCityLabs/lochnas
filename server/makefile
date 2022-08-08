build:
	go build -buildvcs=false -o ../server.bin server && \
	cd ../ && \
	chmod +x server.bin

run: 
	../server.bin

apps-stop:
	../server.bin -apps stop
apps-start:
	../server.bin -apps start

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

