# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
	
EAPI=2
inherit eutils subversion autotools java-pkg-opt-2 flag-o-matic

DESCRIPTION="The Open Source Microscopy Software"
HOMEPAGE="http://valelab.ucsf.edu/~MM/MMwiki/"
ESVN_REPO_URI="https://valelab.ucsf.edu/svn/micromanager2/trunk"
ESVN_BOOTSTRAP="mmUnixBuild.sh"
ESVN_REVISION=9145

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64"
IUSE="+java ieee1394"

RDEPEND="java? (
		>=virtual/jre-1.5
	)
	ieee1394? ( media-libs/libdc1394 )"

DEPEND="dev-lang/swig
	dev-libs/boost
	java? ( 
		>=virtual/jdk-1.5 
		sci-biology/imagej
		dev-java/bsh
		dev-java/commons-math:2
		dev-java/swingx:1.6
		dev-java/swing-layout:1
		dev-java/absolutelayout
		dev-java/jfreechart:1.0
		dev-lang/clojure:1.3
	)"

if use java; then
	IMAGEJ_DIR=/usr/share/imagej
else
	IMAGEJ_DIR="no"
fi
LAUNCHER_NAME=${PN}

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	subversion_bootstrap
	
	# ESVN_PATCHES won't apply after bootstrap, so must use epatches
	epatch ${FILESDIR}/with-imagej_including_r4111_regression.patch \
		|| die "patching ./configure.in failed"
	epatch ${FILESDIR}/subst_acqEngine_CLASSEXT_for_JARPATHs.patch \
		|| die "patching ./acqEngine/Makefile.am failed"
	epatch ${FILESDIR}/subst_plugins_CLASSEXT_for_JARPATHs.patch \
		|| die "patching ./plugins/Makefile.am failed"

	eautoconf || die "eautoconf to apply patched configure.in failed"
	# FIXME	eautoreconf should replace eautoconf and subversion_bootstrap
	#	lines, but dies because ./Makefile.am searches for the
	#	non-existent SecretDeviceAdapters directory
	#eautoreconf || die "eautoreconf to apply patched configure.in failed"
}

src_configure() {
        use java && append-cppflags $(java-pkg_get-jni-cflags)

	econf --with-imagej=${IMAGEJ_DIR} || die
}

src_compile() {
	if use java ; then
		# -j1 is needed for an upstream bug:
		# ./plugins/Makefile.am uses and clears a single `build'
		# directory which prevents multiple plugins from being
		# built simultaneously
		emake -j1 || die
	else
		emake || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
}
