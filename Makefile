SITE_NAME := zbrow.io
GIT_HASH := $(shell git rev-parse --short HEAD)    
GIT_SRC := $(shell git remote get-url --all origin)    
BUILD_DATE := $(shell date -I)
BUILD_DATETIME := $(shell date)

ARTIFACT := zbrow.io.tar.gz
TAINER := /tmp/lxc-zbrow.io
USER := $(shell whoami)


staging:
	rm -rf stage
	mkdir -p stage
	cp -r zbrow.io/* stage/
	sed -i \
		-e 's/{{BUILD_DATE}}/$(BUILD_DATE)/' \
		-e 's/{{BUILD_DATETIME}}/$(BUILD_DATETIME)/' \
		-e 's/{{GIT_HASH}}/$(GIT_HASH)/' \
		-e 's|{{GIT_SRC}}|$(GIT_SRC)|' stage/*.html
	jq -n \
		--arg build_date "$(BUILD_DATE)" \
		--arg build_datetime "$(BUILD_DATETIME)" \
		--arg git_hash "$(GIT_HASH)" \
		--arg git_src "$(GIT_SRC)" \
		'$$ARGS.named' > stage/buildstamp.json

clean:
	rm -rf dist/*
	rm -rf stage/*

dev-up: staging
	docker run -d --name $(SITE_NAME) -p80:80 -v ./stage:/usr/share/nginx/html nginx

dev-down:
	docker rm -f $(SITE_NAME)

dev-restart: dev-down dev-up

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

build-lxc: clean-lxc staging
	mkdir -p $(TAINER) build
	sudo debootstrap --no-check-gpg jammy $(TAINER)
	sudo mount -o bind /dev/pts $(TAINER)/dev/pts
	sudo mount -o bind /proc $(TAINER)/proc
	sudo touch $(TAINER)/etc/locale.gen 
	sudo chroot $(TAINER) /bin/bash -c 'locale-gen en_US.UTF-8'
	# install required packages
	echo 'deb http://us.archive.ubuntu.com/ubuntu/ jammy universe' | sudo tee -a $(TAINER)/etc/apt/sources.list
	sudo chroot $(TAINER) /bin/bash -c 'apt-get update -y'
	sudo chroot $(TAINER) /bin/bash -c 'apt-get install -y openssh-server'
	# setup ansible user
	sudo chroot $(TAINER) /bin/bash -c "useradd -m $(USER)"
	echo "$(USER) ALL=(ALL) NOPASSWD: ALL" | sudo tee $(TAINER)/etc/sudoers.d/ansible-sudo
	# setup passwordless ssh for ansible user
	sudo chroot $(TAINER) /bin/bash -c 'mkdir /home/$(USER)/.ssh'
	cat /home/$(USER)/.ssh/id_rsa.pub | sudo tee $(TAINER)/home/$(USER)/.ssh/authorized_keys
	sudo chroot $(TAINER) /bin/bash -c 'chown -R $(USER):$(USER) /home/$(USER)/.ssh'
	#
	# the rest of the owl
	#
	# clean up
	sudo umount $(TAINER)/dev/pts
	sudo umount $(TAINER)/proc
	sudo tar -czf build/$(ARTIFACT) -C $(TAINER)/ .
	sha256sum build/$(ARTIFACT) > build/SHA256SUMS
	sudo chown $(USER) build/$(ARTIFACT)

deploy-lxc:
	. ./sourceme; \
		ssh-keygen -f "/home/$(USER)/.ssh/known_hosts" -R $${ZBROW_IO_STAGING_IP}
	. ./sourceme; \
		ansible-playbook $${ANSIBLE_PLAYBOOK}
	. ./sourceme; \
		ansible-playbook -e DEBUG_SITE=$(SITE_NAME) $${ANSIBLE_PB_SET_DEBUG}

clean-lxc:
	sudo umount $(TAINER)/dev/pts || /bin/true
	sudo umount $(TAINER)/proc || /bin/true
	sudo rm -rf $(TAINER)
	rm -rf build/
