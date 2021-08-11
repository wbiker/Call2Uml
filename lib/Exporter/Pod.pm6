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
    for %classes<inheritance>.flat -> $inherit {
        %classes-to-save<inheritance>.push: "{$inherit.value.subst("::", '_', :g)} <|-- {$inherit.key.subst("::", '_', :g)}";
    }
    for %classes<relationships>.flat -> $relation {
        %classes-to-save<relationships>.push: "{$relation.key.subst("::", '_', :g)} --o {$relation.value.Str.subst("::", '_', :g)} : Aggregation";
    }

    my $file_content = render-template($file_template, %classes-to-save);
    $!file-path.spurt($file_content);
}