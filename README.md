<img align="right" width="300" src="./icons/badge.svg" />

# ⋈ GitButler Flathub

This is the flatpak packaging code for the [GitButler](https://github.com/gitbutlerapp/gitbutler) desktop application.

## Setup Build Prerequisites

0. Install [just](https://just.systems/man/en/packages.html) project command
   runner.

### Automatic

1. Install `flatpak-builder-tools` and `flatpak-builder`

```sh
$ just install
```

2. Generate sources

```sh
$ just sources
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
python -m venv venv
source venv/bin/activate
pip install poetry
poetry install

python flatpak-cargo-generator.py /opt/gitbutler/gitbutler/Cargo.lock -o cargo-sources.json
```

## Building

After you've got the prerequisites installed and the cargo and node source files
generated, we can build the actual flatpak.

```
$ just flatpak 

# or to auto install after building: 
$ just flatpak --install 
```

If you used installed, you can now run the flatpak via `flatpak run com.gitbutler.app`, if you're not building for local consumption, continue on to the next step.

## Bundling

Finally, to export an archive for sharing, you can generate a `com.gitbutler.app.flatpak` file in the root of the repository.

```
$ just bundle
```

## License

MIT


