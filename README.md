# GitButler Flathub

## Setup Build Prerequisites

1. Clone flatpak-builder-tools

```
git clone https://github.com/flatpak/flatpak-builder-tools
```

2. Generate node `generated-sources.json`

```
# Generate package-lock.json from our pnpm-lock.yaml
npx pnpm-lock-to-npm-lock pnpm-lock.yaml

# Run generated package-lock.json through `flatpak-node-generator`
/home/ndo/.local/bin/flatpak-node-generator npm package-lock.json
```

3. Generate cargo `cargo-sources.json`

```
cd flatpak-builder-tools/cargo
python3 -m venv venv
source venv/bin/activate
pip install poetry
poetry install

python3 flatpak-cargo-generator.py /opt/gitbutler/gitbutler/Cargo.lock -o cargo-sources.json
```
