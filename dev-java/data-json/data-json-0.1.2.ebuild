# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit java-pkg-2 java-ant-2

DESCRIPTION="JSON in Clojure"
HOMEPAGE="https://github.com/clojure/data.json"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE="source"

SRC_URI="https://github.com/clojure/data.json/tarball/data.json-0.1.2
         -> data.json-${PV}.tar.gz"
S=${WORKDIR}/clojure-data.json-5a17048

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

src_prepare() {
	addwrite ${ROOT}/root/.m2/

	mvn ant:ant
}

src_install() {
	java-pkg_dojar target/data.json-${PV}.jar
}
