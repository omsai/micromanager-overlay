# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit java-pkg-2 vcs-snapshot

DESCRIPTION="Assume NG makes it possible to add JUnit-like assumptions to TestNG"
HOMEPAGE="https://github.com/hierynomus/assumeng"
SRC_URI="https://github.com/hierynomus/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

COMMON_DEPEND="dev-java/testng:6
		dev-java/slf4j-api
		dev-java/hamcrest-core:1.2"
DEPEND=">=virtual/jdk-1.5
		${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.5
		${COMMON_DEPEND}"

src_compile() {
	local dest="build"
	mkdir ${dest}
	ejavac -classpath "$(java-pkg_getjars testng:6,slf4j-api,hamcrest-core:1.2)" \
		-d "${dest}" \
		$(find src/main/ -name '*.java')
	jar cf "${PN}.jar" -C ${dest} nl || die
}

src_install() {
	java-pkg_dojar "${PN}.jar"
}
