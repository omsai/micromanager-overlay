# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
	
EAPI=2
inherit eutils subversion autotools java-pkg-opt-2 flag-o-matic java-utils-2

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
		dev-lang/clojure-contrib:1.1
		dev-util/clooj
	)"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	subversion_bootstrap

	if use java; then
		# making and clearing a single `build' directory prevents
		# multiple plugins from being built simultaneously
		sed -i -e 's/build/$@/' plugins/Makefile.am

		eautoconf || die "eautoconf for patched Makefile.am failed"
		# FIXME	eautoreconf should replace eautoconf and 
		#	subversion_bootstrap lines, but dies because 
		#	./Makefile.am searches for the non-existent
		#	SecretDeviceAdapters directory
		#eautoreconf || die "eautoreconf for patched Makefile.am failed"
	fi
}

src_configure() {
	if use java; then
		append-cppflags $(java-pkg_get-jni-cflags)

		IMAGEJ_DIR=$(dirname \
			$(dirname `java-pkg_getjar imagej ij.jar`) \
			)

		ebegin 'Creating symlinks to .jar dependencies...'
		mkdir -p ../3rdpartypublic/classext/
		pushd ../3rdpartypublic/classext/
		java-pkg_jar-from bsh bsh.jar bsh-2.0b4.jar
		java-pkg_jar-from swingx-1.6 swingx.jar swingx-0.9.5.jar
		java-pkg_jar-from commons-math-2 commons-math.jar commons-math-2.0.jar
		java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.4.jar
		java-pkg_jar-from absolutelayout absolutelayout.jar AbsoluteLayout.jar
		java-pkg_jar-from jfreechart-1.0 jfreechart.jar JFreeChart-1.0.13.jar
		java-pkg_jar-from jcommon-1.0 jcommon.jar jcommon-1.0.16.jar
		java-pkg_jar-from imagej,clojure-1.3,clojure-contrib-1.1
#		clooj,
#		gproto,
#		data.json,
		popd
		eend
	else
		IMAGEJ_DIR='no'
	fi

	econf --with-imagej=${IMAGEJ_DIR} || die
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	java-pkg_dolauncher \
		--main ij.ImageJ \
		--java_args \
			-Xmx1024m \
			-Dswing.aatext=true \
			-Dawt.useSystemAAFontSettings=on \
			-Djava.library.path=/usr/lib/micro-manager \
			-cp ${IJ_CP} \
		${PN}
}
