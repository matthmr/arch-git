# Maintainer: Dan McGee <dan@archlinux.org>

pkgname=git
pkgver=2.12.0
pkgrel=1
pkgdesc="the fast distributed version control system"
arch=(i686 x86_64)
url="http://git-scm.com/"
license=('GPL2')
depends=('curl' 'expat>=2.0' 'perl-error' 'perl>=5.14.0' 'openssl' 'pcre')
makedepends=('python2' 'emacs' 'libgnome-keyring' 'xmlto' 'asciidoc')
optdepends=('tk: gitk and git gui'
            'perl-libwww: git svn'
            'perl-term-readkey: git svn'
            'perl-mime-tools: git send-email'
            'perl-net-smtp-ssl: git send-email TLS support'
            'perl-authen-sasl: git send-email TLS support'
            'python2: various helper scripts'
            'subversion: git svn'
            'cvsps2: git cvsimport'
            'gnome-keyring: GNOME keyring credential helper')
replaces=('git-core')
provides=('git-core')
install=git.install
validpgpkeys=('96E07AF25771955980DAD10020D04E5A713660A7') # Junio C Hamano
source=("https://www.kernel.org/pub/software/scm/git/git-$pkgver.tar.xz"
        "https://www.kernel.org/pub/software/scm/git/git-$pkgver.tar.sign"
        git-daemon@.service
        git-daemon.socket)
sha256sums=('1821766479062d052cc1897d0ded95212e81e5c7f1039786bc4aec2225a32027'
            'SKIP'
            '3bc3250d9e04b05c41975c01f85f512d3386d60b41475cbc7292bc88148852f6'
            'ac4c90d62c44926e6d30d18d97767efc901076d4e0283ed812a349aece72f203')

build() {
  export PYTHON_PATH='/usr/bin/python2'
  cd "$srcdir/$pkgname-$pkgver"
  make prefix=/usr gitexecdir=/usr/lib/git-core \
    CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    USE_LIBPCRE=1 \
    NO_CROSS_DIRECTORY_HARDLINKS=1 \
    MAN_BOLD_LITERAL=1 \
    all doc

  make -C contrib/emacs prefix=/usr
  make -C contrib/credential/gnome-keyring
  make -C contrib/credential/libsecret
  make -C contrib/subtree prefix=/usr gitexecdir=/usr/lib/git-core all doc
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
  make prefix=/usr gitexecdir=/usr/lib/git-core \
    CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    USE_LIBPCRE=1 \
    NO_CROSS_DIRECTORY_HARDLINKS=1 \
    MAN_BOLD_LITERAL=1 \
    NO_SVN_TESTS=y \
    DEFAULT_TEST_TARGET=prove \
    GIT_PROVE_OPTS="$jobs -Q" \
    GIT_TEST_OPTS="--root=/dev/shm/git-test" \
    test
}

package() {
  export PYTHON_PATH='/usr/bin/python2'
  cd "$srcdir/$pkgname-$pkgver"
  make prefix=/usr gitexecdir=/usr/lib/git-core \
    CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    USE_LIBPCRE=1 \
    NO_CROSS_DIRECTORY_HARDLINKS=1 \
    MAN_BOLD_LITERAL=1 \
    INSTALLDIRS=vendor DESTDIR="$pkgdir" install install-doc

  # bash completion
  mkdir -p "$pkgdir"/usr/share/bash-completion/completions/
  install -m644 ./contrib/completion/git-completion.bash "$pkgdir"/usr/share/bash-completion/completions/git
  # fancy git prompt
  mkdir -p "$pkgdir"/usr/share/git/
  install -m644 ./contrib/completion/git-prompt.sh "$pkgdir"/usr/share/git/git-prompt.sh
  # emacs
  make -C contrib/emacs prefix=/usr DESTDIR="$pkgdir" install
  # gnome credentials helper
  install -m755 contrib/credential/gnome-keyring/git-credential-gnome-keyring \
      "$pkgdir"/usr/lib/git-core/git-credential-gnome-keyring
  make -C contrib/credential/gnome-keyring clean
  # libsecret credentials helper
  install -m755 contrib/credential/libsecret/git-credential-libsecret \
      "$pkgdir"/usr/lib/git-core/git-credential-libsecret
  make -C contrib/credential/libsecret clean
  # subtree installation
  make -C contrib/subtree prefix=/usr gitexecdir=/usr/lib/git-core DESTDIR="$pkgdir" install install-doc
  # the rest of the contrib stuff
  cp -a ./contrib/* $pkgdir/usr/share/git/

  # scripts are for python 2.x
  sed -i 's|#![ ]*/usr/bin/env python$|#!/usr/bin/env python2|' \
    $(find "$pkgdir" -name '*.py') \
    "$pkgdir"/usr/share/git/remote-helpers/git-remote-bzr \
    "$pkgdir"/usr/share/git/remote-helpers/git-remote-hg
  sed -i 's|#![ ]*/usr/bin/python$|#!/usr/bin/python2|' \
    "$pkgdir"/usr/share/git/svn-fe/svnrdump_sim.py

  # remove perllocal.pod, .packlist, and empty directories.
  rm -rf "$pkgdir"/usr/lib/perl5

  # git-daemon via systemd socket activation
  install -D -m 644 "$srcdir"/git-daemon@.service "$pkgdir"/usr/lib/systemd/system/git-daemon@.service
  install -D -m 644 "$srcdir"/git-daemon.socket "$pkgdir"/usr/lib/systemd/system/git-daemon.socket
}
