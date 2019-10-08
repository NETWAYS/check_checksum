#!/bin/bash

set -ex

cd "$(readlink -f "$(dirname "$0")")"

gen_random() {
    (< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c500)
}

: "${NETWORK_ENABLED:=1}"

TEMPDIR="$(mktemp -d)"

finish() {
    rm -rf "$TEMPDIR"
}
trap finish EXIT SIGINT SIGTERM

echo "Generating some testfiles"
gen_random | tee "$TEMPDIR"/test1.txt
gen_random | tee "$TEMPDIR"/test2.txt
gen_random | tee "$TEMPDIR"/test3.txt

echo "Testing against clean checksum"
for method in md5 sha1 sha256 sha512; do
    echo "Testing method $method"
    "${method}sum" "$TEMPDIR"/test*.txt | tee "$TEMPDIR"/checksum."$method"
    ./check_checksum -c "$TEMPDIR"/checksum."$method" -m "$method"
done

echo "Testing against manipulated files"
echo blubb | tee -a "$TEMPDIR"/test1.txt
# not touching test2
: | tee "$TEMPDIR"/test3.txt

for method in md5 sha1 sha256 sha512; do
    echo "Testing method $method"
    if ./check_checksum -c "$TEMPDIR"/checksum."$method" -m "$method"; then
        echo "Check should have failed"; false
    fi
done

echo "Testing strict mode"
pushd "$TEMPDIR"
sha256sum ./*.txt | tee checksum.unstrict
echo "000 bla.txt" | tee -a checksum.unstrict
popd
# this will pass in non-strict mode...
./check_checksum -c "$TEMPDIR"/checksum.unstrict -p "$TEMPDIR" -m "sha256"
if ./check_checksum -c "$TEMPDIR"/checksum.unstrict -p "$TEMPDIR" -m "sha256" -S; then
    echo "Check should have failed"; false
fi

echo "Testing relative filenames"
pushd "$TEMPDIR"
sha256sum ./*.txt | tee checksum.relative
popd
./check_checksum -c "$TEMPDIR"/checksum.relative -p "$TEMPDIR" -m "sha256"

echo "Testing required files"
./check_checksum -c "$TEMPDIR"/checksum.relative -p "$TEMPDIR" -m "sha256" -f test1.txt
if ./check_checksum -c "$TEMPDIR"/checksum.relative -p "$TEMPDIR" -m "sha256" -f testNOT.txt; then
    echo "Check should have failed!"; false
fi

echo "Test with checksum on commandline"
opt=()
while read -r line; do
  checksum="$(cut -d' ' -f1 <<<"$line")"
  file="$(cut -d' ' -f3 <<<"$line")"

  opt+=(-C "$checksum" -f "$file")
done < <(sha512sum "$TEMPDIR/"*.txt)

./check_checksum "${opt[@]}"

if [ "${NETWORK_ENABLED}" -eq 1 ]; then
  echo "Testing with remote file from GitHub"
  ./check_checksum \
    -C f7e0ec38f23911a02aaefd46df416289bfcb647b037334d722f0d9c611b232a2ede47fa75aa1a2a8f332aee95210bed8f738a1e9a949a9a9449faf17c800cd60 \
    -f https://github.com/NETWAYS/check_checksum/raw/master/test/fixture.txt
fi

echo "All tests completed successfully!"
