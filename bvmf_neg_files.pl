#!/usr/bin/perl
# \author: (c) Copyright Two Roads Technological Solutions Pvt Ltd 2011


=begin comment
Layout of NEG file (Trades)

Header/Trailer
-------------------------------------------------------------
Column                Initial Position   Lenght   Description
-------------------------------------------------------------
Identification                       1        2   RH Header - RT Trailer
Name of file                         4       20   Name of file
Initial date                        25       10   Initial date of file
End date                            36       10   End date of file
Total of lines                      47        9   Contain the total of lines when the file Trailer record

Details
-------------------------------------------------------------
Column                Initial Position   Lenght   Description
-------------------------------------------------------------
1 Session Date                         1       10   Session date
2 Instrument Symbol                   12       50   Instrument identifier
3 Trade Number                        63       10   Trade number
4 Trade Price                         74       20   Trade price
5 Traded Quantity                     95       18   Traded quantity
6 Trade Time                         114       15   Trade time (format HH:MM:SS.NNNNNN)
7 Trade Indicator                    127        1   Trade indicador: 1 - Trade  / 2 - Trade cancelled
8 Buy Order Date                     129       10   Buy order date
9 Sequential Buy Order Number        140       15   Sequential buy order number
10 Secondary Order ID - Buy Order     156       15   Secondary Order ID -  Buy Order.
11 Aggressor Buy Order Indicator      172        1   0 - Neutral (Order was not executed) / 1 - Aggressor / 2 - Passive
12 Sell Order Date                    174       10   Sell order sell date
13 Sequential Sell Order Number       185       15   Sequential sell order number
14 Secondary Order ID - Sell Order    201       15   Secondary Order ID -  Buy Order.
15 Aggressor Sell Order Indicator     217        1   0 - Neutral (Order was not executed) / 1 - Aggressor / 2 - Passive
16 Cross Trade Indicator              219        1   Define if the cross trade was intentional: 1 - Intentional / 0 - Not Intentional
17 Buy Member                         221        8   Entering Firm (Buy Side) - Available from March/2014
18 Sell Member                        230        8   Entering Firm (Sell Side) - Available from March/2014

Obs: Delimiter of details columns ';' (semilocon)


Layout of OFER_CPA file (Buy Orders)

Header/Trailer
-------------------------------------------------------------
Column                Initial Position   Lenght   Description
-------------------------------------------------------------
Identification                       1        2   RH Header - RT Trailer
Name of file                         4       20   Name of file
Initial date                        25       10   Initial date of file
End date                            36       10   End date of file
Total of lines                      47        9   Contain the total of lines when the file Trailer record

Details
-------------------------------------------------------------
Column                Initial Position   Lenght   Description
-------------------------------------------------------------
Session Date                         1       10   Session date
Instrument Symbol                   12       50   Instrument identifier
Order Side    63        1   "1" Buy Order /  "2" Sell Order
Sequential Order Number             65       15   Sequential order number
Secondary Order ID                  81       15   Secondary Order ID
Execution Type                      97        3  Valid values: 1 - New / 2 - Update / 3 - Cancel / 4 - Trade / 5 - Reentry / 6 - New Stop Price / 7 - Rejected / 8 - Removed / 9 - Stop Price Triggered / 11 - Expired / 12 - Eliminated 
Priority Time                      101       15   Order time entry in system (format HH:MM:SS.NNN), used as priority indicator
Priority Indicator                 117       10   Priority indicator
Order Price                        128       20   Order price
Total Quantity of Order            149       18   Total quantity of order
Traded Quantity of Order           168       18   Traded quantity of order
Order Date                         187       10   Order date
Order Datetime entry               198       19   Order datetime entry (format AAAA-MM-DD HH:MM:SS)
Order Status                       218        1   Order status: 0 - New / 1 - Partially Filled / 2 - Filled / 4 - Canceled / 5 - Replaced / 8 - Rejected / C - Expired
Aggressor Indicator                220        1   0 - Neutral (Order was not executed) / 1 - Aggressor / 2 - Passive
Member                             222        8   Entering Firm - Available from March/2014

Obs: Delimiter of details columns ';' (semilocon)


=end comment

=cut


use strict;
use warnings;


my $HOME_DIR = $ENV{'HOME'};

my $shc_ = $ARGV [ 0 ];
my $date_ = $ARGV [ 1 ];
my $input_dir_ = $ARGV [ 2 ];


my $do_trades_ = 0;
my $do_bids_ = 0;
my $do_asks_ = 0;

if ( $ARGV [ 3 ] == 0 )
{
    $do_trades_ = 1;
    $do_bids_ = 1;
    $do_asks_ = 1;
}
if ( $ARGV [ 3 ] == 1 )
{
    $do_trades_ = 1;
}
if ( $ARGV [ 3 ] == 2 )
{
    $do_bids_ = 1;
}
if ( $ARGV [ 3 ] == 3 )
{
    $do_asks_ = 1;
}



## TRADES ##
my $trades_file_ = $input_dir_."/NEG_".$date_.".TXT";

# file name is NEG_20170612.TXT
# grep VALE5  NEG_20170612.TXT  | awk '{print $6" "$7" "$4" "$5" "}'
# date yyyy-mm-dd
my $fdate_ = sprintf("%04d-%02d-%02d", int(($date_/10000)), (int($date_ / 100) % 100), ($date_ % 100));



if ( $do_trades_ == 1 ) {
    my $cmd_ = "awk -F';' '{ gsub(\" \", \"\") ; if ( ( \$2 == \"$shc_\" ) && ( \$1 == \"$fdate_\" ) ) print \$6\" \"\$11\" \"\$15\" \"\$5\" \"\$4 }' $trades_file_" ;
    print $cmd_."\n";
    my @trades_ = `$cmd_`;
#print(@trades_);
#17:56:21.693 2 1 000000000000000200 000000000025.200000
#17:58:08.859 1 2 000000000000001000 000000000025.240000
#17:59:31.725 1 2 000000000000000100 000000000025.240000
#17:59:47.675 1 2 000000000000000600 000000000025.240000
    
# $6 take time convert to BRT_HHMM and call ~/infracore/scripts/get_unix_time.pl $date_ BRT_1001
# then add SS to it
    my $p_unix_time_ = -1;
    my $p_side_ = "";
    my $p_price_ = -1;

    my $t_size_ = 0;
    foreach my $trade_ (@trades_) {

	my @tks_ = split(" ", $trade_);

# time
	my $unix_time_;
	my @time_tks_ = split(":", $tks_[0]);
	my $fmt_ = sprintf("BRT_%02d%02d", $time_tks_[0], $time_tks_[1]);
	#~/infracore/scripts/get_unix_time.pl 20170612 BRT_1018
	my $cmd_ = "~/infracore/scripts/get_unix_time.pl ".$date_." ".$fmt_;
	$unix_time_ = `$cmd_`;
	$unix_time_ = $unix_time_ + $time_tks_[2];

# B/S
	my $side_;
	if ( $tks_[1] == 1 && $tks_[2] == 2 ) {
	    $side_ = "B";
	}
	elsif ( $tks_[1] == 2 && $tks_[2] == 1 ) {
	    $side_ = "S";
	}
	else {
	    $side_ = "-";
	}

# price
	my $price_ = $tks_[4];
	$price_ =~ s/^0+// ;

# if both $11 and $15 are same then we dont the side so lets ignore that for now
# other wise we can get the side of the trade if ($11, $15) == (1, 2) S 
# if ($11, $15) == (2, 1) B ; if ($11, $15) == (1, 1) || (2, 2) ignore


# $5 trade size

# $4 trade price

#
# size
	if ( $p_unix_time_ == $unix_time_ && 
	     $p_side_ eq $side_ && 
	     $p_price_ == $price_ ) {

	    $t_size_ = $t_size_ + int ( $tks_[3] );
	    next;

	} else {
	    # print previous line excluding the first time
	    if ( $t_size_ > 0 ) {
		print $p_unix_time_." ".$p_side_." ".$t_size_." ".$p_price_."\n";
	    }

	    # create new line
	    $p_unix_time_ = $unix_time_;
	    $p_side_ = $side_;
	    $p_price_ = $price_;

	    $t_size_ = int($tks_[3]);
	}
	
    }

    if ( $t_size_ )
    {
	print $p_unix_time_." ".$p_side_." ".$t_size_." ".$p_price_."\n";
    }

}
 

## BID ##
# we keep top 10 highest prices including size, so at any point i know the l1 bid price
if ( $do_bids_ == 1 ) {

    my $bid_file_ = $input_dir_."/OFER_CPA_".$date_.".TXT";
# new ( add )
# update ( modify )
# cancel ( remove )
# combinations possible
#$6 $14
#Execution Type  Order Status
# processing these for now
#001 0
#002 5 
#003 4
#004 1
#004 2

# ignoring iceberg orders
#005 0
#005 1

# ignoring these
#011 C

#Execution Type                      97        3  Valid values: 1 - New / 2 - Update / 3 - Cancel / 4 - Trade / 5 - Reentry / 6 - New Stop Price / 7 - Rejected / 8 - Removed / 9 - Stop Price Triggered / 11 - Expired / 12 - Eliminated 
#Order Status                       218        1   Order status: 0 - New / 1 - Partially Filled / 2 - Filled / 4 - Canceled / 5 - Replaced / 8 - Rejected / C - Expired
#ignore others
    my $cmd_ = "awk -F';' '{ gsub(\" \", \"\") ; if ( ( \$2 == \"$shc_\" ) && ( \$1 == \"$fdate_\" ) ) print \$7\" \"\$6\" \"\$9\" \"\$10\" \"\$11\" \"\$14 }' $bid_file_" ;
    print $cmd_."\n";
    my @bids_ = `$cmd_`;

#002 000000000025.120000 000000000000001000 000000000000000000 5
#003 000000000025.120000 000000000000001000 000000000000000000 4
#001 000000000025.220000 000000000000001000 000000000000000000 0
#002 000000000025.240000 000000000000001000 000000000000000000 5
#004 000000000025.240000 000000000000001000 000000000000001000 2

    # we operate using push and shift and maintain an array of 1024 size
    # 1024 is best price ( highest bid ) l1
    # push at the end
    # shift from the begin
    # so we have a reverse array (thats fine)!
    my @bid_top_prices_ ;
    $bid_top_prices_[1024] = 0;
    my $p_base_price_ = 0;
    foreach my $bid_ (@bids_) {
	my @tks_ = split(" ", $bid_);

	## time
	my $unix_time_;
	my @time_tks_ = split(":", $tks_[0]);
	my $fmt_ = sprintf("BRT_%02d%02d", $time_tks_[0], $time_tks_[1]);
	#~/infracore/scripts/get_unix_time.pl 20170612 BRT_1018
	my $cmd_ = "~/infracore/scripts/get_unix_time.pl ".$date_." ".$fmt_;
	$unix_time_ = `$cmd_`;
	$unix_time_ = $unix_time_ + $time_tks_[2];
	
	if ( $tks_[1] == "001" ) { # NEW
	    my $base_price_ = $tks_[2] / 0.01 ;
	    print $base_price_." ".$p_base_price_;
	    if ( $base_price_ > $p_base_price_ ) {
		my $lowest_price_ = shift @bid_top_prices_;
		$bid_top_prices_[1024] = ($tks_[5] - $tks_[4]);
		$p_base_price_ = $base_price_;
	    } else {
		my $idx_ = (1024 - ($p_base_price_ - $base_price_));
		if ( $idx_ > 0 ) {
		    $bid_top_prices_[$idx_] += ($tks_[5] - $tks_[4]);
		}
	    }
	} elsif ( $tks_[1] == "002" ) { # UPDATE
	    my $base_price_ = $tks_[2] / 0.01 ;
	    print $base_price_." ".$p_base_price_;
	    
	} elsif ( $tks_[1] == "003" ) { # CANCEL
	} elsif ( $tks_[1] == "004" ) { # TRADE
	}
	print "\n";
    }
	

}


