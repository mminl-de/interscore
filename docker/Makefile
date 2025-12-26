STREAM_NUMBER ?= 0

build:
	$(MAKE) -C .. js b-fast
	docker buildx build --load -t obs-ws -f Dockerfile ../

export:
	docker save obs-ws -o obs-ws.tar

run:
	docker run -it -p 5900:5900 -p $(shell echo $$((1935+$(STREAM_NUMBER)))):$(shell echo $$((1935+$(STREAM_NUMBER)))) -v /home/mrmine/.ssh:/root/.ssh:ro -e STREAM_NUMBER="$(STREAM_NUMBER)" obs-ws
debug:
	docker run -d --name obs-ws -v /home/mrmine/.ssh:/root/.ssh:ro obs-ws

clean:
	docker system prune -a --volumes
