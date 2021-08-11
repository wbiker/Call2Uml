unit class RelationshipBuilder;

method get-relationships(%classes) {
    my @classes-to-scan := %classes<classes>;

    my $class-names = @classes-to-scan.map(*<definition><name>).flat.Set;

    my @relations = self.get-relations(@classes-to-scan, $class-names);
    my @inheritance = self.get-inheritance(@classes-to-scan, $class-names);

    %classes<relationships> = @relations if @relations.elems > 0;
    %classes<inheritance> = @inheritance if @inheritance.elems > 0;
    return %classes;
}

method get-relations(@classes, $class-names) {
    my @class-with-types = @classes.grep({ $_<attributes>.grep({$_<type>.Bool && $class-names{$_<type>}}) });
    return [] unless @class-with-types.elems > 0;

    my %relationships;
    for @class-with-types -> $class {
        my $class-name = $class<definition><name>;

        for $class<attributes>.flat -> $attribute {
            next unless $class-names{$attribute<type>};

            %relationships{$class-name}.push: $attribute<type>;
        }
    }

    return %relationships;
}

method get-inheritance(@classes, $class-names) {
    return [] unless @classes.grep(*<definition><inheritance>.elems > 0);

    my %inheritances;
    my @classes-with-inheritance = @classes.grep({$_<definition><inheritance>.elems > 0});
    for @classes-with-inheritance -> $class {
        my $class-name = $class<definition><name>;
        for $class<definition><inheritance>.flat -> $inherit {
            if $class-names{$inherit} {
                %inheritances{$class-name}.push: $inherit;
            }
        }
    }

    return %inheritances;
}