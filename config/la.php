<?php

function colorize($la,$cpu_s)
{
	$cl=$la/$cpu_s;	
 	if($cl<0.70){
 		// ok 
 		$r_class="ok";
 	}
 	elseif($cl<1){
 		// warn
		$r_class="warn";
 	}else{
 		// fail
		$r_class="fail";
 	};

 
  return '<span class="'.$r_class.'">'.$la.'</span>';
};
	
	$la_1=$argv[1];
	$la_5=$argv[2];
	$la_15=$argv[3];
	$nproc=$argv[4];

	echo colorize($la_1,$nproc)." ".colorize($la_5,$nproc)." ".colorize($la_15,$nproc)."\n";
?>