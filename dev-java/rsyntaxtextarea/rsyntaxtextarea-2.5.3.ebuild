# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

JAVA_PKG_IUSE="doc"
inherit java-pkg-2 java-ant-2

MY_PN=RSyntaxTextArea
MY_P=${MY_PN}-${PV}

DESCRIPTION="${MY_PN} is a syntax highlighting text component written in Swing"
HOMEPAGE="http://fifesoft.com/${PN}/"
SRC_URI="https://github.com/bobbylight/${MY_PN}/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5"

S=${WORKDIR}/${MY_P}
EANT_BUILD_TARGET="make-jar"
EANT_DOC_TARGET="make-javadoc"
JAVA_ANT_CLASSPATH_TAGS="${JAVA_ANT_CLASSPATH_TAGS} javadoc"

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dojavadoc javadoc
}
