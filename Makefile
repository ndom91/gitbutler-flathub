OS := $(shell uname)
.PHONY: install sources flatpak bundle clean lint

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

flatpak:
	flatpak-builder --verbose --force-clean --user --install-deps-from=flathub --repo=repo --install builddir com.gitbutler.app.yml
	# flatpak run org.flatpak.Builder --verbose --keep-build-dirs --user --install --force-clean build com.gitbutler.app.yml --repo=.repo

lint:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest com.gitbutler.app.yml
	# appstreamcli validate com.gitbutler.app.metainfo.xml

bundle:
	flatpak build-bundle .repo com.gitbutler.app.flatpak com.gitbutler.app

clean:
	rm -rf .flatpak-builder build/
# flatpak remove com.gitbutler.app -y --delete-data
