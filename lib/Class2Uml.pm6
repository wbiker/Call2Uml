use Cro::WebApp::Template;

use Grammar::Class;
use RakuClass;

unit class Class2Uml;

method parse(IO::Path $file) {
    my $file_content = $file.slurp(:close);

    my $class_data = Grammar::ClassName.parse($file_content, :actions(Action::ClassName.new)).made;
    without $class_data {
       die "Could not find name in file '$file'";
    }

    my RakuClass $class .= new;
    $class.name = $class_data<name>;
    $class.inheritances = $class_data<inheritance>.flat if $class_data<inheritance>:exists;
    $class.implements = $class_data<implement>.flat if $class_data<implement>:exists;

    my $attribute_data = Grammar::Attributes.subparse($file_content, :actions(Action::Attributes.new)).made;
    $class.attributes = $attribute_data.flat if $attribute_data;

    my $methods = Grammar::Methods.subparse($file_content, :actions(Action::Methods.new)).made;
    $class.methods = $methods.flat if $methods;

    return $class;
}