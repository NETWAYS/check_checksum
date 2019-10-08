check_checksum
==============

Testing files against a checksum reference with an Icinga Plugin

## Requirements

You only need `bash` and the common GNU tools for checksums like:

* `sha1sum`
* `sha256sum`
* `sha512sum`

## Example

Create some files to checksum:

    mkdir /var/cache/app/importantfiles
    cp verifyimportant.data /var/cache/app/importantfiles/

    sha512sum /var/cache/app/importantfiles/* \
      >/etc/icinga2/plugins/checksum-app.sha512sum

    ./check_checksum -m sha512 -c /etc/icinga2/plugins/checksum-app.sha512sum

    ./check_checksum -m sha512 -c /etc/icinga2/plugins/checksum-app.sha512sum \
      -f /var/cache/app/importantfiles/verifyimportant.data

    ./check_checksum -m sha512 \
      -C 3d16674888b7788569056486c0340f2855ed787b656216a542757e2a34255cfa7f6d790f76561599ad843803c61e0051120eb6454a0cfc712b2a2c356e245ac1 \
      -f /var/cache/app/importantfiles/verifyimportant.data

    ./check_checksum -m sha512 \
      -C f7e0ec38f23911a02aaefd46df416289bfcb647b037334d722f0d9c611b232a2ede47fa75aa1a2a8f332aee95210bed8f738a1e9a949a9a9449faf17c800cd60 \
      -f https://github.com/NETWAYS/check_checksum/raw/master/test/fixture.txt

For full help see:

    ./check_checksum -h

## License

    Copyright (c) 2017 NETWAYS GmbH <info@netways.de>
                  2017 Markus Frosch <markus.frosch@netways.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
