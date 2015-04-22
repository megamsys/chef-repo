name             'megam_dns'
maintainer       'Megam Systems'
maintainer_email 'thomasalrin@megam.io'
license          'Apache 2.0'
version          '0.5.0'
description      'Creates a dns record for a vm(assembly in megam)'

recipe            "megam_dns", "Installs megam's seru, and creates a record in AWS route53"

depends "megam_preinstall"
