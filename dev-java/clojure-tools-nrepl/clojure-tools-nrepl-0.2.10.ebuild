# Copyright 2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI=5

inherit java-utils-2

MY_CPN=${PN/clojure-/}
MY_CPN=${MY_CPN//-/.}
MY_CPN=${MY_CPN//_/-}

DESCRIPTION="A Clojure network REPL that provides server, client, common APIs"
HOMEPAGE="https://github.com/clojure/${MY_CPN}"
SRC_URI="https://github.com/clojure/${MY_CPN}/archive/${MY_CPN}-${PV}.tar.gz -> ${P}.tar.gz"
SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-lang/clojure:1.6"
DEPEND="${RDEPEND}
	>=virtual/jdk-1.6"

S=${WORKDIR}/${MY_CPN}-${MY_CPN}-${PV}

src_compile() {
	mkdir -p classes
	java \
		-cp ./src/main/clojure:./classes:$(java-pkg_getjars clojure-1.6) \
		-Djava.awt.headless=true \
		-Dclojure.compile.path=classes \
		clojure.lang.Compile clojure.${MY_CPN} || die "Compile failed"

	jar cf "clojure.${MY_CPN}.jar" -C classes . || die
}

src_install() {
	java-pkg_dojar "clojure.${MY_CPN}.jar"
}
