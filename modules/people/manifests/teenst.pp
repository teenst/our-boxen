class people::teenst {
  ## osx
  # Dock
  include osx::dock::autohide
  
  # キーをおしっぱにして連続入力されるまでのdelayを10ミリ秒に
  class { 'osx::global::key_repeat_delay':
    delay => 10
  } 

  # Universal Access
  include osx::universal_access::enable_scrollwheel_zoom

  # Dock
  include osx::dock::autohide	# Dockを自動的に隠す
  include osx::dock::clear_dock	# 起動中のアプリだけでをDockに表示する
  ## Dockのアイコンサイズを指定(px)50px
  class { 'osx::dock::icon_size':
    size => 50         
  }

  # lib
  include wget
  include java
  include python::2_7_5
  include python::3_3_0
  ## Install a Python package
  python::package { 'virtualenv':
    python_version => '2.7.5',
  }


  # local application for develop
  include virtualbox
  include iterm2::stable
  include sourcetree
  include intellij

  # vagrant
  include vagrant
  # vagrant::box { 'centos-6.4':
  # source => 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box'
  # }
  
  # local application for utility
  include dropbox
  include skype
  include chrome
  include hipchat
  include alfred
  include flux
  include appcleaner
  include keyremap4macbook
  include firefox
  include chrome
  include istatmenus4
  include evernote
  include mplayerx
  include skitch
  include mou


  # via homebrew
  package {
    [
     'tmux',
     'reattach-to-user-namespace', # use tmux to clipbord
     'tig',
     'autoconf',
     'automake',
     'byobu',
     'cmake',
     'colordiff',
     'curl',
     'gist',
     'gnu-sed',
     'lv',
     'mecab',
     'mecab-unidic',
     'nkf',
     'vim',
     'the_silver_searcher',
     'watch',
     'zsh-completions',
     'zsh-syntax-highlighting',
     'tree',
     'testdisk',
     'sl',
     'parallel'
     #'readline',
     ]:
  }
  package { 'emacs':
    install_options => [
                        '--cocoa',
                        ],
  }
  
  # # local application
  # package {
  #   'limechat':
  #     source   => "https://downloads.sourceforge.net/project/limechat/limechat/LimeChat_2.39.tbz?use_mirror=master",
  #     provider => compressed_app;

  #   'GoogleJapaneseInput':
  #     source => "http://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg",
  #     provider => pkgdmg;
  # }



  # ログインシェルをzshに
  package {
    'zsh':
      install_options => [
                          '--disable-etcdir',
                          ];
  }
  file_line {'add zsh to /etx/shells':
    path    => '/etc/shells',
    line    => "${boxen::config::homebrewdir}/bin/zsh",
    require => Package['zsh'],
    before  => Osx_chsh[$::luser];
  }
  osx_chsh { $::luser:
    shell => "${boxen::config::homebrewdir}/bin/zsh";
  }

  $home     = "/Users/${::boxen_user}"
  $gitrepos       = "${home}/gitrepos"
  $dotfiles = "${gitrepos}/dotfiles"

  repository { $dotfiles:
    source  => 'teenst/dotfiles'
  }

  # git-cloneしたらインストールする
  exec { "sh ${dotfiles}/install.sh":
    cwd => $dotfiles,
    creates => "${home}/.zshrc",
    require => Repository[$dotfiles],
    notify  => Exec['submodule-clone'],
  }
  exec { "submodule-clone":
    cwd => $dotfiles,
    command => 'git submodule init && git submodule update',
    require => Repository[$dotfiles],
  }
}
