GO_FILES := $(shell find . -type f -name "*.go")
GO_BUILD := CGO_ENABLED=0 go build -ldflags "-w -s"
GO_TOOLS := gridx/modbus-dev:1.11.latest-linux-amd64
DOCKER_RUN := docker run --rm -v $$PWD:/go/src/github.com/grid-x/modbus -w /go/src/github.com/grid-x/modbus
GO_RUN := ${DOCKER_RUN} ${GO_TOOLS} bash -c

BRANCH := $(shell echo ${BUILDKITE_BRANCH} | sed 's/\//_/g')

all: bin/

.PHONY: test
test:
	diagslave -m tcp -p 5020 & go test -run TCP -v $(shell glide nv)
	socat -d -d pty,raw,echo=0 pty,raw,echo=0 & diagslave -m rtu /dev/pts/1 & go test -run RTU -v $(shell glide nv)
	socat -d -d pty,raw,echo=0 pty,raw,echo=0 & diagslave -m ascii /dev/pts/3 & go test -run ASCII -v $(shell glide nv)

.PHONY: lint
lint:
	golint -set_exit_status

.PHONY: build
build:
	go build

ci_test:
	${GO_RUN} "make test"

ci_lint:
	${GO_RUN} "make lint"

ci_build:
	${GO_RUN} "make build"
