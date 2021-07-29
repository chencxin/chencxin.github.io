image:
	@docker build -t hub.dns.360.cn/dns/athena-book:latest .

push:
	@docker push hub.dns.360.cn/dns/athena-book:latest

build:
	@hugo

run:
	@hugo server -D

run-docker:
	@docker run --rm -d -p 8888:80 --name athena-book hub.dns.360.cn/dns/athena-book:latest

stop:
	@docker stop athena-book

new:
	@hugo new $(md)