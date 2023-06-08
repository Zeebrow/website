ARTIFACT := zbrow.io.tar.gz
SITE_NAME := zbrow.io
GIT_HASH := $(shell git rev-parse --short HEAD)    
GIT_SRC := $(shell git remote get-url --all origin)    
BUILD_DATE := $(shell date -I)
BUILD_DATETIME := $(shell date)

staging:
	rm -rf stage
	mkdir -p stage
	cp -r zbrow.io/* stage/
	sed -i \
		-e 's/{{BUILD_DATE}}/$(BUILD_DATE)/' \
		-e 's/{{BUILD_DATETIME}}/$(BUILD_DATETIME)/' \
		-e 's/{{GIT_HASH}}/$(GIT_HASH)/' \
		-e 's|{{GIT_SRC}}|$(GIT_SRC)|' stage/*.html

clean:
	rm -rf dist/*
	rm -rf stage/*

dev-up: staging
	docker run -d --name $(SITE_NAME) -p80:80 -v ./stage:/usr/share/nginx/html nginx

dev-down:
	docker rm -f $(SITE_NAME)

package: clean staging
	mkdir -p dist
	tar -czf dist/$(ARTIFACT) --transform="s/stage\//zbrow.io\//" stage/
	sha256sum dist/$(ARTIFACT) > dist/SHA256SUMS

deploy: package
	. ./sourceme; \
		ansible-playbook $${ANSIBLE_PLAYBOOK}

set-debug:
	. ./sourceme; \
		ansible-playbook -e DEBUG_SITE=$(SITE_NAME) $${ANSIBLE_PB_SET_DEBUG}


