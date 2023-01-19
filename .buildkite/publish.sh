#!/bin/bash -eu

# Install the `gh` binary if needed
if ! command -v gh &> /dev/null; then
	brew install gh
fi

swift build -c release --arch arm64 --arch x86_64
BUILDDIR=.build/artifacts/release
mkdir -p $BUILDDIR

cp .build/apple/Products/Release/hostmon $BUILDDIR/hostmon
tar -czf hostmon.tar.gz -C $BUILDDIR .
mv hostmon.tar.gz .build/artifacts/hostmon.tar.gz

CHECKSUM=$(openssl sha256 .build/artifacts/hostmon.tar.gz | awk '{print $2}')

echo "Build complete: .build/artifacts/hostmon.tar.gz"
echo "  Checksum: $CHECKSUM"

gh auth status
gh release create $BUILDKITE_TAG --title $BUILDKITE_TAG --notes "Checksum: $CHECKSUM" .build/artifacts/hostmon.tar.gz
