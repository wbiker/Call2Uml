use Cro::WebApp::Template;

unit class Exporter::Pod;

has IO::Path $.file-path is rw;

method save(%classes) {
    my $file_template = %?RESOURCES<ClassDiagram.crotmp>.IO;
    if not $file_template {
        die "Could not find file template: ClassDiagram.crotmp";
    }

    my %classes-to-save;

    for %classes<classes>.flat -> $class {
        $class<definition><name> = $class<definition><name>.subst("::", '_', :g);
        for $class<attributes>.flat -> $attribute {
            $attribute<type> = $attribute<type>.subst("::", '_', :g) if $attribute<type>;
        }
        %classes-to-save<classes>.push: $class;
    }

    %classes-to-save<inheritance>  = self.get-inheritance(%classes);
    %classes-to-save<relationships> = self.get-relations(%classes);

    my $file_content = render-template($file_template, %classes-to-save);
    $!file-path.spurt($file_content);
}

method get-inheritance(%classes --> Array) {
    return [] unless %classes<inheritance>:exists;

    my @inheritances;
    for %classes<inheritance>.flat -> $inherit {
        @inheritances.push: "{$inherit.value.subst("::", '_', :g)} <|-- {$inherit.key.subst("::", '_', :g)}";
    }

    return @inheritances;
}

method get-relations(%classes --> Array) {
    return [] unless %classes<relationships>:exists;

    my @relations;
    for %classes<relationships>.flat -> $relation {
        @relations.push: "{$relation.key.subst("::", '_', :g)} --o {$relation.value.Str.subst("::", '_', :g)} : Aggregation";
    }

    return @relations;
}