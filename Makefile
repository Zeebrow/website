ARTIFACT := website-src.tar.gz
package:
	mkdir -p build
	tar -C src/ -czf build/$(ARTIFACT) ./
	sha256sum build/$(ARTIFACT) > build/SHA256SUMS

clean:
	rm -rf build/*
