# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit git-2 java-pkg-2

DESCRIPTION="Lightweight IDE for Clojure"
HOMEPAGE="https://github.com/arthuredelstein/clooj"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""

EGIT_REPO_URI="https://github.com/arthuredelstein/clooj.git"

DEPEND=">=virtual/jdk-1.6
	dev-java/leiningen"
RDEPEND=">=virtual/jre-1.6"

src_unpack() {
	git-2_src_unpack
}

src_compile() {
	addwrite ${ROOT}/root/.m2/
	addwrite ${ROOT}/root/.java/

	lein uberjar
}

src_install() {
	java-pkg_dojar clooj-0.3.4-standalone.jar
}
