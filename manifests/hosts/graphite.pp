class default-repo {




	yumrepo {


		'epel':
			baseurl => $operatingsystemrelease ? {
				'6.0' => "http://mirror.eurid.eu/epel/6/$hardwaremodel/",
					'*' => "http://mirror.eurid.eu/epel/5/$hardwaremodel/",
			},
				descr => $operatingsystemrelease ? {
					'6.0' => 'Extra Packages for Enterprise Linux 6.x
						',
					'*' => 'Extra Packages for Enterprise Linux 5.x',
				},
				gpgcheck => 0,
				enabled => 1;


		'inuits':
			baseurl => $operatingsystemrelease ? {
				'6.0' => 'http://repo.inuits.be/centos/6/os',
					'*' => 'http://repo.inuits.be/centos/5/os',
			},
				descr => $operatingsystemrelease ? {
					'6.0' => 'inuits CentOS 6.x repo',
					'*' => 'inuits CentOS 5.x repo',
				},
				gpgcheck => 0,
				enabled => 1;


	}
}



node 'default' { 

package {
	"django-tagging": 
	ensure => present;
}



$soft = [ "httpd", "mod_wsgi", "python-fedora-django", "mod_python", "python-zope-interface", "python-twisted-core", "python-memcached", "python-ldap" ]

package { $soft: 
	ensure => present;
}


include default-repo
include graphite
include graphite::demo


	Class ["default-repo"] -> Class ["graphite"] -> Class["graphite::demo"]


service { 'iptables':
	name      => "iptables",
        ensure    => "stopped",
        enable    => false,
        hasstatus => "true" 
}


include logster

logster::graphite {"swa":
  host => '127.0.0.1',
  file => '/var/log/graphite-web/access.log',
  prefix => 'swa'

	}

file {"/etc/httpd/conf.d/welcome.conf":
        ensure => absent;
}


# Satisfy  jps dependency 
package {"java-1.6.0-openjdk-devel": ensure => present; }

include jmxtrans
include jmxtrans::example 


} 

