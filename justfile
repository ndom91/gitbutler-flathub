flatpak_id := "com.gitbutler.app"

default:
	just --list

[group('setup')]
[doc('Install all required dependencies')]
install:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub -y org.flatpak.Builder \
		org.gnome.Platform//47 org.gnome.Sdk//47 \
		runtime/org.freedesktop.Sdk.Extension.rust-stable/x86_64/24.08 \
		runtime/org.freedesktop.Sdk.Extension.node22/x86_64/24.08
	wget -N https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py
	pip install "git+https://github.com/flatpak/flatpak-builder-tools.git#egg=flatpak_node_generator&subdirectory=node"
	pip install aiohttp toml

[group('setup')]
[doc('Generate cargo and node sources files')]
sources:
	python flatpak-cargo-generator.py -o cargo-sources.json /opt/gitbutler/gitbutler/Cargo.lock
	# Need to convert pnpm lock file to npm package-lock.json first
	cd /opt/gitbutler/gitbutler && pnpm dlx pnpm-lock-to-npm-lock pnpm-lock.yaml
	flatpak-node-generator --no-requests-cache -r -o node-sources.json npm /opt/gitbutler/gitbutler/package-lock.json
	# git submodule update --remote --merge

set positional-arguments := true
[group('build')]
[doc('Build the app using flatpak-builder')]
flatpak *INSTALL:
	rustup override add nightly-2024-08-01
	flatpak-builder {{INSTALL}} --force-clean --user --install-deps-from=flathub --repo=repo builddir {{ flatpak_id }}.yml

[group('build')]
[doc('Export the built app as a flatpak bundle')]
bundle:
	flatpak build-bundle repo {{ flatpak_id }}.flatpak {{ flatpak_id }}

[group('dev')]
[doc('Lint the manifest and metainfo files')]
lint:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest {{ flatpak_id }}.yml
	# appstreamcli validate {{ flatpak_id }}.metainfo.xml

[group('dev')]
[doc('Delete build artifacts')]
clean:
	rm -rf .flatpak-builder builddir
	# flatpak remove {{ flatpak_id }} -y --delete-data
