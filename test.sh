#!/bin/bash

set -ex

cd "$(readlink -f "$(dirname "$0")")"

gen_random() {
    (< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c500)
}

TEMPDIR=`mktemp -d`

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
sha256sum *.txt | tee checksum.unstrict
echo "000 bla.txt" | tee -a checksum.unstrict
popd
# this will pass in non-strict mode...
./check_checksum -c "$TEMPDIR"/checksum.unstrict -p "$TEMPDIR" -m "sha256"
if ./check_checksum -c "$TEMPDIR"/checksum.unstrict -p "$TEMPDIR" -m "sha256" -S; then
    echo "Check should have failed"; false
fi

echo "Testing relative filenames"
pushd "$TEMPDIR"
sha256sum *.txt | tee checksum.relative
popd
./check_checksum -c "$TEMPDIR"/checksum.relative -p "$TEMPDIR" -m "sha256"

echo "Testing required files"
./check_checksum -c "$TEMPDIR"/checksum.relative -p "$TEMPDIR" -m "sha256" -f test1.txt
if ./check_checksum -c "$TEMPDIR"/checksum.relative -p "$TEMPDIR" -m "sha256" -f testNOT.txt; then
    echo "Check should have failed!"; false
fi

echo "All tests completed successfully!"
