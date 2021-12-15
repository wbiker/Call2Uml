unit class RelationshipBuilder;

method get-relationships(%classes) {
    my @classes-to-scan := %classes<classes>;

    my $class-names = @classes-to-scan.map(*.name).flat.Set;

    my @relations = self.get-relations(@classes-to-scan, $class-names);
    my @inheritance = self.get-inheritance(@classes-to-scan, $class-names);
    my @implements = self.get-implements(@classes-to-scan, $class-names);

    %classes<relationships> = @relations if @relations.elems > 0;
    %classes<inheritance> = @inheritance if @inheritance.elems > 0;
    %classes<implements> = @implements if @implements.elems > 0;
    return %classes;
}

method get-relations(@classes, Set $class-names) {
    my @class-with-types = @classes.grep({ $_.attributes.grep({$_<type>.Bool && $class-names{$_<type>}}) });
    return [] unless @class-with-types.elems > 0;

    my %relationships;
    for @class-with-types -> $class {
        my $class-name = $class.name;

        for $class.attributes.flat -> $attribute {
            next unless $class-names{$attribute<type>};

            %relationships{$class-name}.push: $attribute<type>;
        }
    }

    return %relationships;
}

method get-inheritance(@classes, Set $class-names) {
    return [] unless @classes.grep(*.inheritances.elems > 0);

    my %inheritances;
    my @classes-with-inheritance = @classes.grep({$_.inheritances.elems > 0});
    for @classes-with-inheritance -> $class {
        my $class-name = $class.name;
        for $class.inheritances.flat -> $inherit {
            if $class-names{$inherit} {
                %inheritances{$class-name}.push: $inherit;
            }
        }
    }

    return %inheritances;
}

method get-implements(@classes, Set $class-names) {
    return [] unless @classes.grep(*.implements.elems > 0);

    my %implements;
    my @classes-with-implements = @classes.grep({$_.implements.elems > 0});
    for @classes-with-implements -> $class {
        my $class-name = $class.name;
        for $class.implements.flat -> $implement {
            if $class-names{$implement} {
                %implements{$class-name}.push: $implement;
            }
        }
    }

    return %implements;
}