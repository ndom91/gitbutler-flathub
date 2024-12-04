<img align="right" width="300" src="./icons/badge.svg" />

# GitButler Flathub

## Setup Build Prerequisites

### Automatic

1. Install `flatpak-builder-tools` and `flatpak-builder`

```sh
$ make install
```

2. Generate sources

```sh
make sources
```

3. Build flatpak

```sh
make flatpak
```

### Manual

We'll need to use the `flatpak-builder-tools` `cargo` as well as `node` builders
to generate the sources JSON inputs for use in the `flatpak-builder` command.

The goal is to generate the required lock file inputs that match the GitButler
version defined in the `com.gitbutler.app.yml` `git` source for GitButler (~`:108`).

1. Clone flatpak-builder-tools

```
git clone https://github.com/flatpak/flatpak-builder-tools
```

2. Generate node `generated-sources.json`

- Using
  [pnpm-lock-to-npm-lock](https://github.com/jakedoublev/pnpm-lock-to-npm-lock)
  to convert our `pnpm-lock.yaml` to something that the flatpak-node-generator
  can consume, `package-lock.json`.
- Then
  [flatpak-node-generator](https://github.com/flatpak/flatpak-builder-tools/tree/master/node)
  to generate the `generated-sources.json` lock file.

```
# Generate package-lock.json from our pnpm-lock.yaml
npx pnpm-lock-to-npm-lock pnpm-lock.yaml

# Run generated package-lock.json through `flatpak-node-generator`
/home/ndo/.local/bin/flatpak-node-generator npm package-lock.json
```

3. Generate cargo `cargo-sources.json`

Using [flatpak-cargo-generator](https://github.com/flatpak/flatpak-builder-tools/tree/master/cargo)

```
cd flatpak-builder-tools/cargo
python3 -m venv venv
source venv/bin/activate
pip install poetry
poetry install

python3 flatpak-cargo-generator.py /opt/gitbutler/gitbutler/Cargo.lock -o cargo-sources.json
```

## Building

After you've got the prerequisites installed and the cargo and node source files
generated, we can build the actual flatpak.

```
$ make flatpak
```


