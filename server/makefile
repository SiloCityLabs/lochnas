build:
	go build -buildvcs=false -o ../server.bin server && \
	cd ../ && \
	chmod +x server.bin

run: 
	../server.bin

install:
	../server.bin -daemon install

update: 
	../server.bin -apps update

apps-stop:
	../server.bin -apps stop
apps-start:
	../server.bin -apps start

test: 
	../server.bin -apps test

notify: 
	../server.bin -server notify

disks:
	../server.bin -disks list

ip:
	../server.bin -ddns ip
refresh:
	../server.bin -ddns refresh
force:
	../server.bin -ddns force

renew:
	../server.bin -domain renew

