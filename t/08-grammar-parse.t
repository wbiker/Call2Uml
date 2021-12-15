use Test;
use lib './lib';

#use Grammar::Parse;

class Statement {
    has $.index;
    has $.name;
    has $.value;
    has @.statements;
}
#my $class = "t/files/class.parse".IO.slurp;
my @class = 'tt'.IO.lines; # slurp(:close);

my %class;
my %statements;
my $statement_index = 0;
my $last_index = 0;
for @class -> $line {
   next unless $line ~~ /^ \s* '-'/;

   if $line ~~ / ^ $<index>=\s* '-' \s+ $<name>=<-[:]>+ ':' $<value>=.*? $ / {
       my $index = 0;
       $index = $<index>.Str.chars if $<index>;

       my $statement;
       $statement = Statement.new(index => $index, name => $<name>.Str, value => $<value>.Str.trim);

       if %class{$index}:exists {
           %class{$index - 2}.statements.push: %class{$index} if $index -2 >= 0;
       }

       if $index < $last_index {
           %statements{$statement_index} = %class{$index}:delete;
           $statement_index++;
       }
       %class{$index} = $statement unless $index == 0 and %class<0>:exists;

       $last_index = $index;
   }

}

dd %class<0>;
dd %statements{0};
#for %statements.sort(*.key.Int) -> $state {
#    dd $state;
#}
#for %class.sort(*.key.Int) -> $entry {
#    say $entry.raku;
#}

#$class = $class.subst(/ ^^ \s*  <-[-]> .*? \n /, '');


# my $match = Grammar::Parse.subparse($class, :actions(Action::Parse.new));
# my $h = $match.made;
# dd $h;

# my $usage = Grammar::Usage.parse($class, :actions(Action::Usage.new));
# say $usage.made;

# my $attributes = Grammar::Attributes.subparse($class, :actions(Action::Attributes.new));
# dd $attributes.made;
# dd $_ for $attributes.made;

#my $methods = Grammar::Methods.subparse($class, :action(Action::Methods.new));
#dd $methods.made;
#dd $_ for $methods.made;

done-testing;
