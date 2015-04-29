# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit vcs-snapshot python-any-r1 java-pkg-2 java-ant-2

DESCRIPTION="Java library for reading and writing data in life sciences image file formats"
HOMEPAGE="http://loci.wisc.edu/software/bio-formats"
SRC_URI="https://github.com/openmicroscopy/${PN}/archive/v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.5
	dev-java/slf4j-api"
RDEPEND=">=virtual/jre-1.5"

EANT_BUILD_TARGET="jars"

S="${WORKDIR}/v${PV}"

pkg_setup() {
	python-any-r1_pkg_setup
	java-pkg-2_pkg_setup
}

src_install() {
	# remove upstream's binary jars
	for file in `ls jar`; do
		rm artifacts/$file
	done

	java-pkg_dojar artifacts/*
}
