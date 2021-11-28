grammar Grammar::Usage {
    regex TOP { .*? <statement_control>* $ }

    token statement_control { '-' \s+ 'statement_control:' \s* 'use' \s+ $<name>=<-[\n]>+ \n }
}

class Action::Usage {
    method TOP($/) {
        say $<statement_control>.elems;
        make [$<statement_control>>>.made];
    }

    method statement_control($/) {
        make $<name>.Str;
        dd $<name>.Str;
    }
}

grammar Grammar::ParseName {
    regex TOP { .*? <package_name> .* }

    token package_name { '- package_def:' \s+ <name> <inheritance>* <implement>* }
    token name { <-[\s;]>+ }
    token inheritance { \s* 'is' \s+ <name> \s* }
    token implement { \s* 'does' \s+ <name> }
}

class Action::ParseName {
    method TOP($/) {
        my $name = $<package_name><name>.made;

        make %(
            name => $name,
            inheritance => $<package_name><inheritance>.elems ?? [$<package_name><inheritance>>>.made] !! [],
            implement => $<package_name><implement>.elems ?? [$<package_name><implement>>>.made] !! [],
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

    token attribute { .*? '- scope_declarator: has' \s+ <type>? \s+ <name> \s+ <modifier>? \n }
    token type { <-[\s $ @ % &]>+ }
    token name { ['$'|'@'|'%'|'&']<-[\s\n]>+ }
    token modifier { <-[\n]>+ }
}

class Action::Attributes {
    method TOP($/) { make $<attribute>.map(*.made).Array  }

    method attribute($/) {
        warn;
        make %(
            name => $<name>.made,
            type => ($<type>.made ?? $<type>.made !! ''),
            modifier => ($<modifier>.made ?? $<modifier>.made !! '')
        )
    }
    method type($/) {
        warn;
        make ~$/ }
    method name($/) {
        warn;
        make ~$/ }
    method modifier($/) {
        warn $/;
        make ~$/ }
}

grammar Grammar::Methods {
    regex TOP { <method>* }

    token method { <keyword> <name> .*? }
    token keyword { 'method_def:' }
    token name { \s+ <-[\s\{\n]>+ }
}

class Action::Methods {
    method TOP($/) { make [$<method>>>.made] }
    method method($/) {
        warn;
        make $<name>.made }
    method name($/) {
        warn;
        make $/.Str }
}