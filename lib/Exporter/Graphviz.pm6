use Cro::WebApp::Template;

unit class Exporter::Graphviz;

has IO::Path $.file-path is rw;

method save(%classes) {
    my $file_template = %?RESOURCES<GraphvizDiagram.crotmp>.IO;
    if not $file_template {
        die "Could not find file template: GraphvizDiagram.crotmp";
    }

    my %classes-to-save;
    %classes-to-save<classes>      = self.get-classes(%classes);
    %classes-to-save<inheritances> = self.get-inheritance(%classes);
    %classes-to-save<relations>    = self.get-relations(%classes);

    my $file_content = render-template($file_template, %classes-to-save);
    $!file-path.spurt($file_content);
}

method get-classes(%classes) {
    return [] unless %classes<classes>:exists;

    my @classes;
    for %classes<classes>.flat -> $class {
        my $label = "$class<name>|";
        if $class<attributes>:exists {
            for $class<attributes>.flat -> $attribute {
                $label ~= $attribute<attribute>;
                $label ~= " : $attribute<type>" if $attribute<type>;
                $label ~= "\\l";
            }
        }
        $label ~= '|';
        if $class<methods>:exists {
            for $class<methods>.flat -> $method {
                $label ~= "{ $method }()\\l";
            }
        }

        @classes.push: {name => $class<name>.subst("::", '_', :g), :$label};
    }

    return @classes;
}

method get-inheritance(%classes --> Array) {
    return [] unless %classes<inheritance>:exists;

    my @inheritance;
    for %classes<inheritance>.flat.sort(*.key) -> $inherit {
        @inheritance.push: "{$inherit.value.subst("::", '_', :g)} -> {$inherit.key.subst("::", '_', :g)} [dir=back]";
    }

    return @inheritance;
}

method get-relations(%classes --> Array) {
    return [] unless %classes<relationships>:exists;

    my @relations;
    for %classes<relationships>.flat -> $relation {
        @relations.push: "{$relation.value.subst("::", '_', :g)} -> {$relation.key.Str.subst("::", '_', :g)} [dir=back]";
    }

    return @relations;
}