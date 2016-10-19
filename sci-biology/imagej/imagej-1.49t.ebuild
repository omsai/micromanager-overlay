# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

JAVA_PKG_IUSE="doc source examples"
inherit java-pkg-2 java-ant-2

ICON="ImageJ.png"

DESCRIPTION="Image Processing and Analysis in Java"
HOMEPAGE="http://rsb.info.nih.gov/ij/"
SRC_URI="http://rsb.info.nih.gov/ij/download/src/ij${PV/./}-src.zip
http://rsb.info.nih.gov/ij/images/${ICON}"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

RDEPEND=">=virtual/jre-1.6"
DEPEND=">=virtual/jdk-1.6
source? ( app-arch/zip )"

S=${WORKDIR}/source

pkg_setup() {
	export EANT_BUILD_TARGET="build"
	export EANT_DOCS_TARGET="javadocs"
	export EANT_EXTRA_ARGS="
-DImageJ.default=${EANT_BUILD_TARGET}
-Djavac.debug=$(use debug && echo on || echo off)
$(use_doc ${EANT_DOCS_TARGET})
"
}

src_install() {
	use doc && java-pkg_dojavadoc ../api/
	use source && java-pkg_dosrc ij/
	use examples && java-pkg_doexamples macros/ plugins/

	doicon ${DISTDIR}/${ICON}
	make_desktop_entry "${PN}" "ImageJ" ${ICON%\.*} \
		"Graphics;Science;Biology"

	java-pkg_dojar *.jar
	java-pkg_dolauncher ${PN} --main ij.ImageJ --pwd /usr/share/imagej/lib
}
