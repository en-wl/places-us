use warnings;
use strict;

use Text::CSV;
use Switch;
use open IN => ':encoding(cp1252)', OUT => ':utf8', ':std';

my %states = (
    'Alabama' => 'AL',
    'Alaska' => 'AK',
    'Arizona' => 'AZ',
    'Arkansas' => 'AR',
    'California' => 'CA',
    'Colorado' => 'CO',
    'Connecticut' => 'CT',
    'Delaware' => 'DE',
    'Florida' => 'FL',
    'Georgia' => 'GA',
    'Hawaii' => 'HI',
    'Idaho' => 'ID',
    'Illinois' => 'IL',
    'Indiana' => 'IN',
    'Iowa' => 'IA',
    'Kansas' => 'KS',
    'Kentucky' => 'KY',
    'Louisiana' => 'LA',
    'Maine' => 'ME',
    'Maryland' => 'MD',
    'Massachusetts' => 'MA',
    'Michigan' => 'MI',
    'Minnesota' => 'MN',
    'Mississippi' => 'MS',
    'Missouri' => 'MO',
    'Montana' => 'MT',
    'Nebraska' => 'NE',
    'Nevada' => 'NV',
    'New Hampshire' => 'NH',
    'New Jersey' => 'NJ',
    'New Mexico' => 'NM',
    'New York' => 'NY',
    'North Carolina' => 'NC',
    'North Dakota' => 'ND',
    'Ohio' => 'OH',
    'Oklahoma' => 'OK',
    'Oregon' => 'OR',
    'Pennsylvania' => 'PA',
    'Rhode Island' => 'RI',
    'South Carolina' => 'SC',
    'South Dakota' => 'SD',
    'Tennessee' => 'TN',
    'Texas' => 'TX',
    'Utah' => 'UT',
    'Vermont' => 'VT',
    'Virginia' => 'VA',
    'Washington' => 'WA',
    'West Virginia' => 'WV',
    'Wisconsin' => 'WI',
    'Wyoming' => 'WY',
    'District of Columbia' => 'DC',
    'Puerto Rico' => 'PR',
);

my @rows;
my $csv = Text::CSV->new ()  # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();


#my %fix = ('Islamorada, Village of Islands village; Florida' => 'Islamorada, Village of Islands village, Florida',
#           'Louisville/Jefferson County metro government (balance), Kentucky' => 'Louisville/Jefferson County metropolitan government (balance), Kentucky',
#           'Carson City, Nevada' => 'Carson City city, Nevada',
#           'Lynchburg, Moore County metropolitan government; Tennessee', 'Lynchburg, Moore County metropolitan government, Tennessee',
           

$/ = "\x0d\x0a";
<>;
<>; 
while ( <> ) {
    chomp;
    $csv->parse($_);
    my ($c0,$c1,$what,$pop) = $csv->fields( $_ );
    $pop =~ s/\(r\d+\)$//;
    switch ($c0) {
        case /^0500000/ {
            my ($name,$loc) = $what =~ /^(.+)[,;] (.+)$/ or die "$what";
            my $type = '';
            die "$loc" unless exists $states{$loc};
            print "county \t$name\t$states{$loc}\t$type\t$pop\n";
        }
        case /^1600000/ {
            #$what =~ /^(.+) (CDP|city|town|village|city and borough|borough|urbana|municipality|village|comunidad|municipality|consolidated government|metro government|metropolitan government|urban county|unified government|)( \(.+\)|)[,;] (.+)$/ or warn $what;
            my ($name,$loc) = $what =~ /^(.+)[,;] (.+)$/ or die "$what";
            my $type = '';
            my $suffix = '';
            $suffix = " $1" if $name =~ s/ (\([A-Z].+\))$//;
            $type = $1 if $name =~ s/ (\(.+\))$//;
            while ($name =~ s/ (CDP|[a-z]+)$//) {
                $type = "$1 $type";
            }
            die "$loc" unless exists $states{$loc};
            print "place\t$name$suffix\t$states{$loc}\t$type\t$pop\n";
        }
        case /^310M100/ {
            my ($name,$loc,$type) = $what =~ /^(.+), (.+) (Micro Area|Metro Area)$/;
            $name =~ s/--/;/g or $name =~ s/-/;/g;
            $loc =~ s/-/;/g;
            print "ma\t$name\t$loc\t$type\t$pop\n";
        }
        case /^400C100/ {
            my ($name,$loc,$type) = $what =~ /^(.+), (.+) (Urbanized Area|Urban Cluster) \(2010\)/ or die;
            $name =~ s/--/;/g;
            $loc =~ s/--/;/g;
            print "ua\t$name\t$loc\t$type\t$pop\n";
        }
    }
    # next if $c0 =~ /^2500000/;
    # die "$what|$pop" unless $pop =~ /^[0-9]+$/;
    # #$what = $fix{$what} if $row->[0] =~ /^1600000/ and defined $fix{$what};
    # switch ($what) {
    #     case /^(.+) (County|Municipio|Census Area|Municipality|Borough|Parish), (.+)$/ {}
    #     case /^(.+) (CDP|city|town|village|city and borough|borough|urbana|municipality|village|comunidad|municipality|consolidated government|metro government|metropolitan government|urban county|unified government)(| \(.+\))[,;] (.+)$/ {}
    #     case /^(.+), (.+) (Micro|Metro) Area$/ {}
    #     case /^(.+), (.+) (Urbanized Area)|(Urban Cluster) \(2010\)/ {}
    #     case /^(.+), (.+) CSA/ {}
    #     else {warn "$c0|$what|$pop" if $pop >= 5000};
    # }
    # push @rows, [$what,$pop];
}
$csv->eof or $csv->error_diag();
#print @rows+0,"\n";

