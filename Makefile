ARTIFACT := zbrow.io.tar.gz
CONTAINER_NAME := website

dev-up:
	docker run -d --name $(CONTAINER_NAME) -p80:80 -v ./src:/usr/share/nginx/html nginx

dev-down:
	docker rm -f $(CONTAINER_NAME)

package: clean
	mkdir -p build
	tar -czf build/$(ARTIFACT) zbrow.io/
	sha256sum build/$(ARTIFACT) > build/SHA256SUMS

clean:
	rm -rf build/*
