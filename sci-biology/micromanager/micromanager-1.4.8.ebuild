# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils subversion

DESCRIPTION="The Open Source Microscopy Software"
HOMEPAGE="http://valelab.ucsf.edu/~MM/MMwiki/"
ESVN_REPO_URI="https://valelab.ucsf.edu/svn/micromanager2/trunk"
ESVN_BOOTSTRAP="mmUnixBuild.sh"
#ESVN_PATCHES="${FILESDIR}/*.patch"
ESVN_REVISION=9145

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64"
IUSE="+imagej ieee1394"

RDEPEND="imagej? (
		sci-biology/imagej
		dev-java/bsh
		dev-java/commons-math
		dev-java/swingx:1.6
		dev-java/swing-layout
		dev-java/absolutelayout
		dev-java/jfreechart
	)
	ieee1394? ( media-libs/libdc1394 )"

DEPEND="dev-lang/swig
	dev-libs/boost
	${RDEPEND}"

IMAGEJ_DIR=/usr/share/imagej
LAUNCHER_NAME=${PN}

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	subversion_bootstrap
	epatch ${FILESDIR}/*.patch
}

src_configure() {
	econf \
		--with-imagej=${IMAGEJ_DIR}
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	local lib
	if use amd64; then
		lib="lib64"
	else
		lib="lib"
	fi

#	if use imagej ; then
#		einfo "Creating launcher script..."
#		insinto /usr/bin
#		cat <<EOF >${LAUNCHER_NAME}
##!/bin/bash
#cd $IMAGEJ_DIR
#export LD_LIBRARY_PATH=.:/usr/local/lib:/usr/${lib}/micro-manager:$IMAGEJ_DIR
#java -mx1200m -Djava.library.path=/usr/${lib}/micro-manager:$IMAGEJ_DIR \
#-Dplugins.dir=$IMAGEJDIR \
#-cp $IMAGEJDIR/ij.jar ij.ImageJ
#EOF

	dodir "/usr/${lib}/${PN}"
	emake DESTDIR="${D}" install || die "make install failed"
}
