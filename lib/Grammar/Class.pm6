grammar Grammar::ClassName {
    regex TOP { .*? <unit>? <class_tag> <name> <inheritance>* <implement>* .* }

    token unit { 'unit' \s+ }
    token class_tag { 'class' \s+ }
    token name { <-[\s { ; \n]>+ \s* }
    token inheritance { 'is' \s+ <name> \s* }
    token implement { 'does' \s+ <name> }
}

class Action::ClassName {
    method TOP($/) {
        make %(
            name => $<name>.made,
            inheritance => [$<inheritance>>>.made],
            implement => [$<implement>>>.made],
        )
    }

    method name($/) {
        make $/.Str.subst("::", '_', :g).trim;
    }

    method inheritance($/) {
        make $<name>.Str.subst("::", '_', :g).trim;
    }

    method implement($/) {
        make $<name>.Str.subst("::", '_', :g).trim;
    }
}

grammar Grammar::Attributes {
    regex TOP { .*? <attribute>* .* }

    token attribute { \n <has> \s+  <name> \s*  }
    token has {  'has' }
    token type { <-[\s]>+ }
    token name { ['$'|'@'|'%'|'&']<-[;\s]>+ }
    token modifier { <-[;]>+ }
}