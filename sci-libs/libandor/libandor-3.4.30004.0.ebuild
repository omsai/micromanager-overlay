# Copyright 2009-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod autotools multilib

EAPI=2

ZIP="Andor_SDK3_(Linux)_V${PV}.zip"
TARBALL="andor-sdk3-${PV}.tgz"
AUTOTOOLS_FILES="sdk3-autotools.tar.gz"

DESCRIPTION="SDK library for scientific CMOS cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
ZIP_URI="https://www.andor.com/my/ -> ${ZIP}"
AUTOTOOLS_URI="https://github.com/omsai/sdk3-autotools/tarball/master -> ${AUTOTOOLS_FILES}"
SRC_URI="${ZIP_URI} ${AUTOTOOLS_URI}"

LICENSE="Andor-EULA"
SLOT="3"
KEYWORDS="~amd64"
IUSE="+modules"

RESTRICT="fetch"

DEPEND=""
RDEPEND=""

ANDOR_HOME=/opt/andor
SDKLIB=""

pkg_nofetch() {
	einfo "Due to license restrictions, download:"
	einfo "${ZIP_URI}"
	einfo "and"
	einfo "${AUTOTOOLS_URI}"
	einfo "and place it in ${DISTDIR}"
}

src_unpack() {
	# Upstream double bags tarball in a zip file
	#
	unpack ${A}
	mv ${WORKDIR}/${TARBALL} ${DISTDIR}
	unpack ${TARBALL}
	cp -r andor/* .

	ebegin "Copying autotools files patch"
	touch README NEWS AUTHORS
	cp -r omsai*/* .
	eautoreconf
	eend
}

src_install() {
	emake DESTDIR="${D}" install || die

	ebegin "Creating symlinks to binary libraries"
	for lib_name in $( ls ${D}usr/$(get_libdir)/*.${PV} \
				| xargs -n1 basename ) ; do
		lib_base=${lib_name%%.*}
		dosym ${lib_base}.so.${PV} \
			/usr/$(get_libdir)/${lib_base}.so.3 \
			|| die "failed to install symlink"
	done
	eend
}
