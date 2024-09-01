# Maintainer: Thomas Rijpstra <thomas at fourlights dot nl>
pkgname=auto-brightness
pkgver=1.0.1
pkgrel=1
pkgdesc="A script to automatically adjust screen brightness based on ambient light"
arch=('any')
url="https://github.com/trijpstra-fourlights/auto-brightness"
license=('MIT')
depends=('bash' 'awk' 'iio-sensor-proxy')
source=("auto-brightness.sh"
        "auto-brightness.service"
        "auto-brightness.conf")
sha256sums=('62358fd73d1934261e3259c3075b64605540058c0b9eea92cf240a3b8d5ebf1e'
            '30aa46466e0e531b7834618d4ff582cb25543bfc776d441b6ca320ed5bc7e05f'
            '4a2f4e4a331df6c2e3cda53b0cb38161fd5cff153253166d740d0c86b8d444a8')

package() {
    install -Dm755 "$srcdir/auto-brightness.sh" "$pkgdir/usr/bin/auto-brightness"
    install -Dm644 "$srcdir/auto-brightness.service" "$pkgdir/usr/lib/systemd/system/auto-brightness.service"
    install -Dm644 "$srcdir/auto-brightness.conf" "$pkgdir/usr/share/auto-brightness/examples/auto-brightness.conf"
    install -d "$pkgdir/etc/conf.d/auto-brightness.d"
}

