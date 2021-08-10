use Cro::WebApp::Template;

unit class Exporter::Pod;

has IO::Path $.file-path is rw;

method save(%classes) {
    my $file_template = %?RESOURCES<ClassDiagram.crotmp>.IO;
    if not $file_template {
        die "Could not find file template: ClassDiagram.crotmp";
    }

    say %classes.keys.elems;
    dd %classes;
    my $file_content = render-template($file_template, %classes);
    $!file-path.spurt($file_content);
}