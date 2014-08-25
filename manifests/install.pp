define logparser::install(
	$ensure = 'present',
	$msi_name='LogParser.msi',
	$sourceurl='http://download.microsoft.com/download/f/f/1/ff1819f9-f702-48a5-bbc7-c9656bc74de8',
	$temp_target='C:\temp'
)
{
	Exec{
      tries     => 3,
      try_sleep => 30,
      timeout   => 500,
    }
	
	$sourcelocation="${sourceurl}/${msi_name}"
	
	file { "${temp_target}":
		ensure => "directory"
	}
	
	$target_file = "${temp_target}\\${msi_name}"	
    $base_cmd = '$wc = New-Object System.Net.WebClient;'
	$cmd = "${base_cmd}\$wc.DownloadFile('${sourcelocation}','${target_file}')"
    notice("Downloading $sourcelocation")  
		
	exec{"Download-${target_file}":
	  require   => File["${temp_target}"],
      provider  => powershell,
      command   => $cmd,
      unless    => "if(Test-Path -Path \"${target_file}\" ){ exit 0 }else{exit 1}",
      timeout   => $timeout,
    }
	
	package { 'LogParser':
	  source => "${target_file}",
	  ensure => installed,
	  require => Exec["Download-${target_file}"],
	  install_options => ['/qn'],	  
	}  
}
