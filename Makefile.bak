SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c  
.DELETE_ON_ERROR:
.PHONY: install sources flatpak flatpak-local lint bundle clean

install:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub -y org.flatpak.Builder \
		org.gnome.Platform//47 org.gnome.Sdk//47 \
		runtime/org.freedesktop.Sdk.Extension.rust-stable/x86_64/24.08 \
		runtime/org.freedesktop.Sdk.Extension.node22/x86_64/24.08
	wget -N https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py
	pip install "git+https://github.com/flatpak/flatpak-builder-tools.git#egg=flatpak_node_generator&subdirectory=node"
	pip install aiohttp toml

sources:
	python flatpak-cargo-generator.py -o cargo-sources.json /opt/gitbutler/gitbutler/Cargo.lock
	# Need to convert pnpm lock file to npm package-lock.json first
	cd /opt/gitbutler/gitbutler && pnpm dlx pnpm-lock-to-npm-lock pnpm-lock.yaml
	flatpak-node-generator --no-requests-cache -r -o node-sources.json npm /opt/gitbutler/gitbutler/package-lock.json
	# git submodule update --remote --merge

flatpak:
	rustup override add nightly-2024-08-01
	flatpak-builder --force-clean --user --install-deps-from=flathub --repo=repo builddir com.gitbutler.app.yml

flatpak-local:
	flatpak-builder --install --force-clean --user --install-deps-from=flathub --repo=repo builddir com.gitbutler.app.yml

lint:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest com.gitbutler.app.yml
	# appstreamcli validate com.gitbutler.app.metainfo.xml

bundle:
	flatpak build-bundle repo com.gitbutler.app.flatpak com.gitbutler.app

clean:
	rm -rf .flatpak-builder build/
	# flatpak remove com.gitbutler.app -y --delete-data
