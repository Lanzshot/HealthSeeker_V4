#!/usr/bin/perl -w

#########################################################################################################################
#Program:       HealthSeeker_V4.pl                                                                 	 (Dtd: 24/01/08)#
#Created by:    CS Lam, Nyan Lin                                                                                        #
#Function:      Will Crunch the given LOT number health.log files/cells and Crunch                 			#
#               data to your specific folder.					                                        #
#Setup:         To be executed from the healthdev server only!								#
#               If not the program will not work!                                                                       # 
#########################################################################################################################

#--scp SSH password and setting (to login to individual cells)
   use Net::SCP::Expect;
   my $scpe;
#--reading input configuration file
   my $cfgFile = shift;
   printf("ERROR: No configuration file\n   Syntax: autohealthseeker.pl  <autohealthSeekerCruncher.cfg>\n") unless $cfgFile;
   require $cfgFile; 


#--read every lot number
   foreach my $lotNumber (keys %CFG) {
       next if ($lotNumber eq 'CRUNCH_DATA');
       
#--read cellhost type
   my $sgpamdType = sprintf("%s", $CFG{$lotNumber}{CELLHOST});
        printf("This Lot belongs to %s\n", $sgpamdType);
		if ($sgpamdType eq 'sgpamdkslt')	{
			$Configpath = '/home/healthdev/tools/health/config/health_report_AutoSeeker_Kslt';
                        $scpe= Net::SCP::Expect->new(user=>'root',password=>'FujiLinux',auto_yes=>1);
		}
		else	{
			$Configpath = '/home/healthdev/tools/health/config/health_report_AutoSeeker_Hst';
                        $scpe= Net::SCP::Expect->new(user=>'root',password=>'bigfish',auto_yes=>1);
		}


       printf("\nProcessing lot number ....%s\n", $lotNumber);
       my $lotIndex = "health_$lotNumber";
       print("The affected Tprogs lot is  $lotIndex*.log\n");

       #--for every cells reading 
          foreach my $cellNo (@{$CFG{$lotNumber}{CELLNO}}) {
              my $cellHost = sprintf("%s%03d", $CFG{$lotNumber}{CELLHOST}, $cellNo);
	      my   $trgDIR = sprintf("/home/healthdev/public_html/data_Recrunch/%s%03d/", $CFG{$lotNumber}{CELLHOST}, $cellNo);
              my $srcFILES = sprintf("/data/archive/%s/log/%s*.log*", $CFG{$lotNumber}{WORKWEEK}, $lotIndex);

              printf("\nProcessing cell:%s    WW:%s \n", $cellHost, $CFG{$lotNumber}{WORKWEEK});       
	      printf("    Copying HEALTH file to $trgDIR\n");
   	   
              system("mkdir -p $trgDIR");
              $scpe->scp("$cellHost:$srcFILES"," $trgDIR");
              printf("      ... Cell-%s Health files are copied from $srcFILES\n", $cellHost);
   	      printf("      ... Health files Transfer Done!\n");
	  }
   }
   	   
#--option to cruch data - reading option in config file
   if ($CFG{CRUNCH_DATA} eq 'YES') {
       printf("\nCrunching data ..... take a break!!!.\n");
       my $cmd3 = "./automatic_last_known_state_report_generator.sh $Configpath";
       printf("     ... using syntax: $cmd3\n");
       system($cmd3);
       printf("     ... Crunching Done! \n\n");
   }
   else {
       print("\n### Health files Copy Done! ###\n\n\n");
   }

__END__
