# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit git-2 java-utils-2

DESCRIPTION="A small library for getting var information from clojure source code"
HOMEPAGE="https://github.com/arthuredelstein/clj-inspector"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""

EGIT_REPO_URI="https://github.com/arthuredelstein/clj-inspector.git"

DEPEND=">=virtual/jdk-1.6"

RDEPEND=">=dev-lang/clojure-1.3.0
	dev-java/commons-math
	dev-java/data-zip"

src_unpack() {
	git-2_src_unpack

	mkdir ${WORKDIR}/${P}/classes || die "mkdir failed"
	ls ${WORKDIR}/${P}
}

src_compile() {
        java \
		-cp ./src:./classes:$(java-pkg_getjars clojure-1.3,commons-math-2,data-zip) \
		-Djava.awt.headless=true \
		-Dclojure.compile.path=classes \
		clojure.lang.Compile clj-inspector.vars || die "Compile failed"
}
