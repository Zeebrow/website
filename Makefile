ARTIFACT := zbrow.io.tar.gz
CONTAINER_NAME := website
GIT_HASH := $(shell git rev-parse --short HEAD)    
GIT_SRC := $(shell git remote get-url --all origin)    
BUILD_DATE := $(shell date -I)

dev-up:
	docker run -d --name $(CONTAINER_NAME) -p80:80 -v ./src:/usr/share/nginx/html nginx

dev-down:
	docker rm -f $(CONTAINER_NAME)

commit-hash:

package: clean
	mkdir -p dist
	mkdir -p stage
	cp -r zbrow.io/* stage/
	sed -i 's/{{BUILD_DATE}}/$(BUILD_DATE)/' stage/about.html
	sed -i 's/{{GIT_HASH}}/$(GIT_HASH)/' stage/about.html
	sed -i 's|{{GIT_SRC}}|$(GIT_SRC)|' stage/*.html
	tar -czf dist/$(ARTIFACT) --transform="s/stage\//zbrow.io\//" stage/
	sha256sum dist/$(ARTIFACT) > dist/SHA256SUMS

clean:
	rm -rf dist/*
	rm -rf stage/*
