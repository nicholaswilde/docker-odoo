include make_env

NS ?= nicholaswilde
VERSION ?= 14.0
LS ?= 1

IMAGE_NAME ?= odoo
CONTAINER_NAME ?= odoo
CONTAINER_INSTANCE ?= default

.PHONY: push push-latest run rm help vars

## all		: Build all platforms
all: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg ODOO_VERSION=$(VERSION) -f Dockerfile .

## build		: build the current platform (default)
build: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --build-arg ODOO_VERSION=$(VERSION) --build-arg ODOO_RELEASE=$(RELEASE) -f Dockerfile .

## build-latest	: Build the latest current platform
build-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest --build-arg ODOO_VERSION=$(VERSION) --build-arg ODOO_RELEASE=$(RELEASE) -f Dockerfile .

## load   	: Load the release image
load: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) -f Dockerfile --load .

## load-latest  	: Load the latest image
load-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest -f Dockerfile --load .

## push   	: Push the release image
push: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --build-arg ODOO_VERSION=$(VERSION) --build-arg ODOO_RELEASE=$(RELEASE) -f Dockerfile --push .

## push-latest  	: PUsh the latest image
push-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest $(PLATFORMS) --build-arg ODOO_VERSION=$(VERSION) --build-arg ODOO_RELEASE=$(RELEASE) -f Dockerfile --push .

## push-all 	: Push all release platform images
push-all: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg ODOO_VERSION=$(VERSION) --build-arg ODOO_RELEASE=$(RELEASE) -f Dockerfile --push .

## rm   		: Remove the container
rm: stop
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

## run    	: Run the Docker image
run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

## rund   	: Run the Docker image in the background
rund:
	docker run -d --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

## stop   	: Stop the Docker container
stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

## help   	: Show help
help: Makefile
	@sed -n 's/^##//p' $<

## vars   	: Show all variables
vars:
	@echo ODOO_VERSION   : $(VERSION)
	@echo NS        : $(NS)
	@echo IMAGE_NAME      : $(IMAGE_NAME)
	@echo CONTAINER_NAME    : $(CONTAINER_NAME)
	@echo CONTAINER_INSTANCE  : $(CONTAINER_INSTANCE)
	@echo PORTS : $(PORTS)
	@echo ENV : $(ENV)
	@echo PLATFORMS : $(PLATFORMS)
	@echo PLATFORMS_ARM : $(PLATFORMS_ARM)

default: build
