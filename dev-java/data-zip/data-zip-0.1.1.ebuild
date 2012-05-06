# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit java-pkg-2 java-ant-2

DESCRIPTION="Utilities for clojure.zip"
HOMEPAGE="https://github.com/clojure/data.zip"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE="source"

SRC_URI="https://github.com/clojure/data.zip/tarball/data.zip-0.1.1
         -> data.zip-${PV}.tar.gz"
S=${WORKDIR}/clojure-data.zip-a171b4b

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

src_prepare() {
	addwrite ${ROOT}/root/.m2/
	
	mvn ant:ant
}

src_install() {
	java-pkg_dojar target/data.zip-${PV}.jar
}
