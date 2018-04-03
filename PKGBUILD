# Maintainer: Christian Hesse <mail@eworm.de>
# Maintainer: Dan McGee <dan@archlinux.org>

pkgname=git
pkgver=2.17.0
pkgrel=1
pkgdesc="the fast distributed version control system"
arch=(x86_64)
url="http://git-scm.com/"
license=('GPL2')
depends=('curl' 'expat>=2.0' 'perl>=5.14.0' 'perl-error' 'perl-mailtools'
         'openssl' 'pcre2' 'grep' 'shadow')
makedepends=('python2' 'emacs' 'libgnome-keyring' 'xmlto' 'asciidoc')
optdepends=('tk: gitk and git gui'
            'perl-libwww: git svn'
            'perl-term-readkey: git svn'
            'perl-mime-tools: git send-email'
            'perl-net-smtp-ssl: git send-email TLS support'
            'perl-authen-sasl: git send-email TLS support'
            'perl-mediawiki-api: git mediawiki support'
            'perl-datetime-format-iso8601: git mediawiki support'
            'perl-lwp-protocol-https: git mediawiki https support'
            'perl-cgi: gitweb (web interface) support'
            'python2: various helper scripts'
            'subversion: git svn'
            'gnome-keyring: GNOME keyring credential helper')
install=git.install
validpgpkeys=('96E07AF25771955980DAD10020D04E5A713660A7') # Junio C Hamano
source=("https://www.kernel.org/pub/software/scm/git/git-$pkgver.tar."{xz,sign}
        'git-daemon@.service'
        'git-daemon.socket'
        'git-sysusers.conf')
sha256sums=('e916e5e95e81dbeafa7aac5d719c01108b5c814eb90b746695afa1afedf955c7'
            'SKIP'
            '14c0b67cfe116b430645c19d8c4759419657e6809dfa28f438c33a005245ad91'
            'ac4c90d62c44926e6d30d18d97767efc901076d4e0283ed812a349aece72f203'
            '7630e8245526ad80f703fac9900a1328588c503ce32b37b9f8811674fcda4a45')

make_paths=(
  prefix='/usr'
  gitexecdir='/usr/lib/git-core'
  perllibdir="$(/usr/bin/perl -MConfig -wle 'print $Config{installvendorlib}')"
)

make_options=(
  CFLAGS="$CFLAGS"
  LDFLAGS="$LDFLAGS"
  USE_LIBPCRE2=1
  NO_CROSS_DIRECTORY_HARDLINKS=1
  NO_PERL_CPAN_FALLBACKS=1
  MAN_BOLD_LITERAL=1
)

build() {
  export PYTHON_PATH='/usr/bin/python2'
  cd "$srcdir/$pkgname-$pkgver"

  make \
    "${make_paths[@]}" \
    "${make_options[@]}" \
    all doc

  make -C contrib/emacs "${make_paths[@]}"
  make -C contrib/credential/gnome-keyring
  make -C contrib/credential/libsecret
  make -C contrib/subtree "${make_paths[@]}" all doc
  make -C contrib/mw-to-git "${make_paths[@]}" all
  make -C contrib/diff-highlight "${make_paths[@]}"
}

check() {
  export PYTHON_PATH='/usr/bin/python2'
  cd "$srcdir/$pkgname-$pkgver"

  local jobs
  jobs=$(expr "$MAKEFLAGS" : '.*\(-j[0-9]*\).*') || true
  mkdir -p /dev/shm/git-test
  # explicitly specify SHELL to avoid a test failure in t/t9903-bash-prompt.sh
  # which is caused by 'git rebase' trying to use builduser's SHELL inside the
  # build chroot (i.e.: /usr/bin/nologin)
  SHELL=/bin/sh \
  make \
    "${make_paths[@]}" \
    "${make_options[@]}" \
    NO_SVN_TESTS=y \
    DEFAULT_TEST_TARGET=prove \
    GIT_PROVE_OPTS="$jobs -Q" \
    GIT_TEST_OPTS="--root=/dev/shm/git-test" \
    test
}

package() {
  export PYTHON_PATH='/usr/bin/python2'
  cd "$srcdir/$pkgname-$pkgver"
  
  make \
    "${make_paths[@]}" \
    "${make_options[@]}" \
    DESTDIR="$pkgdir" \
    install install-doc

  # bash completion
  mkdir -p "$pkgdir"/usr/share/bash-completion/completions/
  install -m 0644 ./contrib/completion/git-completion.bash "$pkgdir"/usr/share/bash-completion/completions/git
  # fancy git prompt
  mkdir -p "$pkgdir"/usr/share/git/
  install -m 0644 ./contrib/completion/git-prompt.sh "$pkgdir"/usr/share/git/git-prompt.sh
  # emacs
  make -C contrib/emacs "${make_paths[@]}" DESTDIR="$pkgdir" install
  # gnome credentials helper
  install -m 0755 contrib/credential/gnome-keyring/git-credential-gnome-keyring \
      "$pkgdir"/usr/lib/git-core/git-credential-gnome-keyring
  make -C contrib/credential/gnome-keyring clean
  # libsecret credentials helper
  install -m 0755 contrib/credential/libsecret/git-credential-libsecret \
      "$pkgdir"/usr/lib/git-core/git-credential-libsecret
  make -C contrib/credential/libsecret clean
  # subtree installation
  make -C contrib/subtree "${make_paths[@]}" DESTDIR="$pkgdir" install install-doc
  # mediawiki installation
  make -C contrib/mw-to-git "${make_paths[@]}" DESTDIR="$pkgdir" install
  mv "$pkgdir"/Git/Mediawiki.pm "$pkgdir"/usr/share/perl5/vendor_perl/Git/ && rmdir "$pkgdir"/Git # TODO: fix install path!
  # the rest of the contrib stuff
  find contrib/ -name '.gitignore' -delete
  cp -a ./contrib/* $pkgdir/usr/share/git/

  # scripts are for python 2.x
  sed -i 's|#![ ]*/usr/bin/env python$|#!/usr/bin/env python2|' \
    $(find "$pkgdir" -name '*.py') \
    "$pkgdir"/usr/share/git/remote-helpers/git-remote-bzr \
    "$pkgdir"/usr/share/git/remote-helpers/git-remote-hg
  sed -i 's|#![ ]*/usr/bin/python$|#!/usr/bin/python2|' \
    "$pkgdir"/usr/share/git/svn-fe/svnrdump_sim.py

  # git-daemon via systemd socket activation
  install -D -m 0644 "$srcdir"/git-daemon@.service "$pkgdir"/usr/lib/systemd/system/git-daemon@.service
  install -D -m 0644 "$srcdir"/git-daemon.socket "$pkgdir"/usr/lib/systemd/system/git-daemon.socket

  # sysusers file
  install -D -m 0644 "$srcdir"/git-sysusers.conf "$pkgdir"/usr/lib/sysusers.d/git.conf
}
