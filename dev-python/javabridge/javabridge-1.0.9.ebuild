# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 distutils-r1 flag-o-matic

DESCRIPTION="Python wrapper for the Java Native Interface"
HOMEPAGE="github.com/CellProfiler/python-javabridge/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="test"

DEPEND="
dev-java/rhino
>=dev-python/cython-0.18
dev-python/numpy
" # rhino might require 1.7.4 dependency and/or 1.7 slot?
RDEPEND="${DEPEND}"

pkg_setup() {
	java-pkg-2_pkg_setup
}

src_prepare() {
	java-pkg-2_src_prepare
	distutils-r1_src_prepare
}

src_configure() {
	# append-cflags $(java-pkg_get-jni-cflags)
	distutils-r1_src_configure
}

src_compile() {
	java-pkg-2_src_compile
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
}

# Work in progress:
#
# - Manually compile bundled java sources for runnablequeue, test
#
# - Unbundle jar rhino-1.7R4 (bug # 524528 to bump rhino to 1.7.4)
#
# - Fix numpy C API deprecation warning for importing
#   numpy/arrayobject.h
