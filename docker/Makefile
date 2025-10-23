STREAM_NUMBER ?= 0
DYNU_USERNAME ?=
DYNU_PASSWORD ?=

build:
	docker buildx build -t obs-ws -f Dockerfile ../
run:
	docker run -it -p 5900:5900 -p $(shell echo $$((1935+$(STREAM_NUMBER)))):$(shell echo $$((1935+$(STREAM_NUMBER)))) -v /home/mrmine/.ssh:/root/.ssh:ro -e STREAM_NUMBER="$(STREAM_NUMBER)" -e DYNU_USERNAME="$(DYNU_USERNAME)" -e DYNU_PASSWORD="$(DYNU_PASSWORD)" obs-ws
debug:
	docker run -d --name obs-ws -v /home/mrmine/.ssh:/root/.ssh:ro obs-ws
clean:
	docker system prune -a --volumes
