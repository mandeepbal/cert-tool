CGO_ENABLED=0
GOOS=linux
GOARCH=amd64
TAG=${TAG:-latest}
OS="darwin windows linux"
ARCH="amd64 386"
COMMIT=`git rev-parse --short HEAD`

all: deps build

deps:
	@godep restore

clean:
	@rm -rf cert-tool cert-tool_*

build: deps
	@godep go build -a -tags 'netgo' -ldflags "-w -X github.com/ehazlett/cert-tool/version.GITCOMMIT $(COMMIT) -linkmode external -extldflags -static" .

build-cross: deps
	@gox -os=$(OS) -arch=$(ARCH) -ldflags "-w -X github.com/ehazlett/cert-tool/version.GITCOMMIT $(COMMIT)" -output="cert-tool_{{.OS}}_{{.Arch}}"

image: build
	@echo Building image $(TAG)
	@docker build -t ehazlett/cert-tool:$(TAG) .

release: deps build image
	@docker push ehazlett/cert-tool:$(TAG)

test:
	@bats test/integration/cli.bats test/integration/certs.bats

.PHONY: all deps build clean image test release
