STREAM_NUMBER ?= 1

build:
	docker buildx build -t obs-ws -f Dockerfile ../
run:
	docker run -it -v /home/mrmine/.ssh:/root/.ssh:ro obs-ws -e STREAM_NUMBER=$(STREAM_NUMBER)
debug:
	docker run -d --name obs-ws -v /home/mrmine/.ssh:/root/.ssh:ro obs-ws
clean:
	docker system prune -a --volumes
