# Define: php::mod
#
# This define configures php mods-available to all SAPI using php5{en,dis}mod
#
# == Parameters
# 
# [*disable*]
#   Set to 'true' to disable the php mod-availables to all SAPI using php5{dis}mod
#   Default: false, i.e, Set the php mod-availables to all SAPI using php5{en}mod.
#
# [*service_autorestart*]
#   whatever we want a module installation notify a service to restart.
#
# == Usage
# 
# [name] is filename without .ini extension from /etc/php5/mods-available/<name>.ini
# 
# php::mod { "<name>": }
# 
# == Example
# 
# This will configure php5-mcrypt module to all SAPI
# 
# php::mod { "mcrypt": }
# 
# $mods = ["mcrypt", "mongo"]
# php::mod { "$mods": }
# 
# This will unconfigure php5-xdebug module to all SAPI
# 
# php::mod { "xdebug":
#   disable => true,
# }
# 
# Note that you may include or declare the php class when using
# the php::module define
#
define php::mod (
  $disable              = false,
  $service_autorestart  = '',
  $path                 = '/usr/bin:/bin:/usr/sbin:/sbin',
  $package              = $php::package,
  $version              = '5',
  ) {

  include php
  case $version {
   '7': {
      $php_mod_enable   = 'phpenmod'
      $php_mod_disable  = 'phpdismod'
      $pkg_fpm          = 'php7.0-fpm'
      $phpquery         = 'phpquery'
    }
    default: {
      $php_mod_enable   = 'php5enmod'
      $php_mod_disable  = 'php5dismod'
      $pkg_fpm          = 'php5-fpm'
      $phpquery         = 'php5query'
    }
  }

  $real_service_autorestart = $service_autorestart ? {
    true    => "Service[${php::service}]",
    false   => undef,
    ''      => $php::service_autorestart ? {
      true    => "Service[${php::service}]",
      false   => undef,
    }
  }

  if $disable {
      exec { "php_mod_tool_disable_${name}":
        command => "${php_mod_disable} ${name}",
        path    => $path,
        notify  => $real_service_autorestart,
        require => Package[$package],
        onlyif  => "${phpquery} -M | grep -q '^${name}$'",
      }
  } else {
      exec { "php_mod_tool_enable_${name}":
        command => "${php_mod_enable} ${name}",
        path    => $path,
        notify  => $real_service_autorestart,
        require => Package[$package],
        unless  => "${phpquery} -M | grep -q '^${name}$'",
      }
  }

}
