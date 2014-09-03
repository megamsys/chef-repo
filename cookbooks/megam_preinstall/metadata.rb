name             'megam_preinstall'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          'Apache 2.0'
version          '0.5.0'
description      'Somethings to do before install megam apps'

recipe            "megam_preinstall::default", "Installs essential packages."
recipe            "megam_preinstall::account", "Creates megam user and necessary directories."



