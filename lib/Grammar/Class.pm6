grammar Grammar::ClassName {
    regex TOP { .*? <unit>? <class_tag> <name> <inheritance>* <implement>* .* }

    token unit { 'unit' \s+ }
    token class_tag { ['class' | 'role'] \s+ }
    token name { <-[\s { ; \n]>+ \s* }
    token inheritance { 'is' \s+ <name> \s* }
    token implement { 'does' \s+ <name> }
}

class Action::ClassName {
    method TOP($/) {
        my $name = $<name>.made;
        my $is-role = False;

        if $<class_tag>.Str.trim eq 'role' {
            $is-role = True;
        }

        make %(
            name => $name,
            inheritance => [$<inheritance>>>.made],
            implement => [$<implement>>>.made],
            is-role => $is-role,
        )
    }

    method name($/) {
        my $name = $/.Str.trim;
        $name .= subst(/ '[' <-[\]]> + ']' /, '');

        make $name;
    }

    method inheritance($/) {
        make $<name>.Str.trim;
    }

    method implement($/) {
        my $name = $<name>.Str.trim;
        $name .= subst(/'[' <-[\]]>+ ']'/, '');

        make $name;
    }
}

grammar Grammar::Dependencies {
    regex TOP { <dependency>* }

    token dependency { .*? <keyword> \s+ <name> <-[\n]>+ \n }
    token keyword {[ 'use' | 'need' ] }
    token name { <-[\s;]>+ }
}

grammar Grammar::Attributes {
    regex TOP { <attribute>* }

    token attribute { .*? <has> \s+ <type>? \s* <name> \s* <modifier>? ';' }
    token has {  'has' }
    token type { <-[\s $ @ % &]>+ }
    token name { ['$'|'@'|'%'|'&']<-[;\s]>+ }
    token modifier { <-[;]>+ }
}

class Action::Attributes {
    method TOP($/) { make $<attribute>.map(*.made).Array  }

    method attribute($/) { make %(name => $<name>.made, type => ($<type>.made ?? $<type>.made !! ''), modifier => ($<modifier>.made ?? $<modifier>.made !! '')) }
    method type($/) { make ~$/ }
    method name($/) { make ~$/ }
    method modifier($/) { make ~$/ }
}

grammar Grammar::Methods {
    token TOP { <method>* }

    token method { .*? <keyword> <name> .*? }
    token keyword { 'method' }
    token name { \s+ <-[\s\(\{]>+ }
}

class Action::Methods {
    method TOP($/) { make [$<method>>>.made] }
    method method($/) { make $<name>.made }
    method name($/) { make $/.Str }
}