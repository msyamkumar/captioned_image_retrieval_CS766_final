#!/usr/bin/perl

$out = ``;
@splitParts = split('\n', $out);
my @fNames;
my %hash_fNames = {};

for($i = 0; $i < $#splitParts; $i++) {
    print $splitParts[$i];
    print "\n";
    if($splitParts[$i] =~ /([A-z]+).*/) {
        #print $1;
        #print "\n";
        my $tag = $1;
        print $tag;
        if(exists($hash{$tag}))  {
            print "Yes, exists!";
        }
        else { 
            $hash{$tag} = 1;
        }
        push(@fNames, $tag);
    }
}

print @fNames;
