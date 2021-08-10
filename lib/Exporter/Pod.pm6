use Cro::WebApp::Template;

unit class Exporter::Pod;

has IO::Path $.file-path is rw;

method save(%classes) {
    my $file_template = %?RESOURCES<ClassDiagram.crotmp>.IO;
    if not $file_template {
        die "Could not find file template: ClassDiagram.crotmp";
    }

    my %classes-to-save;
    %classes-to-save<classes> = %classes<classes>;

    for %classes<inheritance>.flat -> $inherit {
        %classes-to-save<inheritance>.push: "{$inherit.value} <|-- {$inherit.key}";
    }
    for %classes<relationships>.flat -> $relation {
        %classes-to-save<relationships>.push: "{$relation.key} --o {$relation.value.Str.subst("::", '_', :g)} : Aggregation";
    }

    my $file_content = render-template($file_template, %classes-to-save);
    $!file-path.spurt($file_content);
}