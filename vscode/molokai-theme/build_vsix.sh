#!/usr/bin/env bash
# Package this folder as a .vsix (a zip with a manifest) without needing npm/vsce.
# Usage: build_vsix.sh <out.vsix>
set -euo pipefail
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$src/package.json")"
mkdir -p "$stage/extension"
cp "$src/package.json" "$stage/extension/"
cp -R "$src/themes" "$stage/extension/"

cat > "$stage/[Content_Types].xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension=".json" ContentType="application/json"/>
  <Default Extension=".vsixmanifest" ContentType="text/xml"/>
</Types>
XML

cat > "$stage/extension.vsixmanifest" <<XML
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema-design/2011">
  <Metadata>
    <Identity Language="en-US" Id="molokai-nvim" Version="$version" Publisher="nhendy"/>
    <DisplayName>Molokai (nvim)</DisplayName>
    <Description xml:space="preserve">Port of the Neovim molokai colorscheme.</Description>
    <Categories>Themes</Categories>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.60.0"/>
    </Properties>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code"/>
  </Installation>
  <Dependencies/>
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/>
  </Assets>
</PackageManifest>
XML

rm -f "$out"
(cd "$stage" && zip -qr "$out" "[Content_Types].xml" extension.vsixmanifest extension)
echo "$out"
