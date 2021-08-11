use Cro::WebApp::Template;

unit class Exporter::Graphviz;

has IO::Path $.file-path is rw;

method save(%classes) {
    my $file_template = %?RESOURCES<GraphizDiagram.crotmp>.IO;
    if not $file_template {
        die "Could not find file template: GraphizDiagram.crotmp";
    }

    my %classes-to-save;

    for %classes<classes>.flat -> $class {
        my $label = "$class<definition><name>|";
        if $class<attributes>:exists {
            for $class<attributes>.flat -> $attribute {
                $label ~= $attribute<attribute>;
                $label ~= " : $attribute<type>" if $attribute<type>;
                $label ~= "\\l";
            }
        }
        $label ~= '|';
        for $class<methods>.flat -> $method {
            $label ~= "{$method}()\\l";
        }
        %classes-to-save<classes>.push: {name => $class<definition><name>.subst("::", '_', :g), :$label};
    }

    %classes-to-save<inheritances> = self.get-inheritance(%classes);
    %classes-to-save<relations> = self.get-relations(%classes);

    my $file_content = render-template($file_template, %classes-to-save);
    $!file-path.spurt($file_content);
}

method get-inheritance(%classes) {
    return [] unless %classes<inheritance>:exists;

    my @inheritance;
    for %classes<inheritance>.flat.sort(*.key) -> $inherit {
        @inheritance.push: "{$inherit.value.subst("::", '_', :g)} -> {$inherit.key.subst("::", '_', :g)} [dir=back]";
    }

    return @inheritance;
}

method get-relations(%classes) {
    return [] unless %classes<relationships>:exists;

    my @relations;
    for %classes<relationships>.flat -> $relation {
        dd $relation;
        @relations.push: "{$relation.value.subst("::", '_', :g)} -> {$relation.key.Str.subst("::", '_', :g)} [dir=back]";
    }

    return @relations;
}