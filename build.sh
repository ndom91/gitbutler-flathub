#!/usr/bin/env bash

flatpak-builder \
  --force-clean \
  --user \
  --install \
  --install-deps-from=flathub \
  --repo=repo builddir com.gitbutler.app.yml
