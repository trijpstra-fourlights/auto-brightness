# Maintainer: Thomas Rijpstra <thomas at fourlights dot nl>
pkgname=auto-brightness
pkgver=1.0.0
pkgrel=1
pkgdesc="A script to automatically adjust screen brightness based on ambient light"
arch=('any')
url="https://github.com/trijpstra-fourlights/auto-brightness"
license=('MIT')
depends=('bash' 'awk')
source=("auto-brightness.sh"
        "auto-brightness.service"
        "auto-brightness.conf")
sha256sums=('62358fd73d1934261e3259c3075b64605540058c0b9eea92cf240a3b8d5ebf1e'
            '96a519a558b1fea7daa01550a30767b9b48d2a0e285b16d90e422946c33ef9df'
            '4a2f4e4a331df6c2e3cda53b0cb38161fd5cff153253166d740d0c86b8d444a8')

package() {
    install -Dm755 "$srcdir/auto-brightness.sh" "$pkgdir/usr/bin/auto-brightness"
    install -Dm644 "$srcdir/auto-brightness.service" "$pkgdir/usr/lib/systemd/system/auto-brightness.service"
    install -Dm644 "$srcdir/auto-brightness.conf" "$pkgdir/usr/share/auto-brightness/examples/auto-brightness.conf"
    install -d "$pkgdir/etc/conf.d/auto-brightness.d"
}

