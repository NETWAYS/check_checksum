check_checksum
==============

Testing files against a checksum reference with an Icinga Plugin

## Requirements

You only need `bash` and the common GNU tools for checksums like:

* `md5sum`
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
