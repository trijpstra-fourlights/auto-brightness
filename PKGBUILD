# Maintainer: Thomas Rijpstra <thomas at fourlights dot nl>
pkgname=auto-brightness
pkgver=1.0.2
pkgrel=1
pkgdesc="A script to automatically adjust screen brightness based on ambient light"
arch=('any')
url="https://github.com/trijpstra-fourlights/auto-brightness"
license=('MIT')
depends=('bash' 'awk' 'iio-sensor-proxy')
source=("auto-brightness.sh"
        "auto-brightness.service"
        "auto-brightness.conf"
	"wait-for-als-sensor.sh")
sha256sums=('62358fd73d1934261e3259c3075b64605540058c0b9eea92cf240a3b8d5ebf1e'
            '0cb8db3700b878e82c42cdd2e95893d12dc926f106742d6bccfe1a7f395f2800'
            '4a2f4e4a331df6c2e3cda53b0cb38161fd5cff153253166d740d0c86b8d444a8'
            'e208630a23360de4e336649c6bc0970b3c3dfecf5b906d3e334530dd279be9c6')

package() {
    install -Dm755 "$srcdir/auto-brightness.sh" "$pkgdir/usr/bin/auto-brightness"
    install -Dm755 "$srcdir/wait-for-als-sensor.sh" "$pkgdir/usr/lib/auto-brightness/wait-for-als-sensor.sh"
    install -Dm644 "$srcdir/auto-brightness.service" "$pkgdir/usr/lib/systemd/system/auto-brightness.service"
    install -Dm644 "$srcdir/auto-brightness.conf" "$pkgdir/usr/share/auto-brightness/examples/auto-brightness.conf"
    install -d "$pkgdir/etc/conf.d/auto-brightness.d"
}

