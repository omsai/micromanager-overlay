# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit git-2

DESCRIPTION="Slamhound rips your ns form apart and reconstructs it"
HOMEPAGE="https://github.com/technomancy/slamhound"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""

EGIT_REPO_URI="https://github.com/technomancy/slamhound.git"

DEPEND=">=virtual/jdk-1.6"

RDEPEND="=dev-lang/clojure-1.3.0"

src_unpack() {
	git-2_src_unpack
}
