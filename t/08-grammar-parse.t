use Test;
use lib './lib';

use Grammar::Parse;

my $class = "t/files/class.parse".IO.slurp;

# my $match = Grammar::ParseName.subparse($class, :actions(Action::ParseName.new));
# my $h = $match.made;
# dd $h;

# my $usage = Grammar::Usage.parse($class, :actions(Action::Usage.new));
# say $usage.made;

# my $attributes = Grammar::Attributes.subparse($class, :actions(Action::Attributes.new));
# dd $attributes.made;
# dd $_ for $attributes.made;

my $methods = Grammar::Methods.subparse($class, :action(Action::Methods.new));
dd $methods.made;
dd $_ for $methods.made;

done-testing;
