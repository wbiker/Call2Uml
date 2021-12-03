use Logger;
use Cro::WebApp::Template;

use Grammar::Class;
use RakuClass;

unit class Class2Uml;

has $log = Logger.get;

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
    $class.is-role = $class_data<is-role>;

    my $attribute_data = Grammar::Attributes.subparse($file_content, :actions(Action::Attributes.new)).made;
    $class.attributes = $attribute_data.flat if $attribute_data;

    my $methods = Grammar::Methods.subparse($file_content, :actions(Action::Methods.new)).made;
    $class.methods = $methods.flat if $methods;

    my $dependencies = Grammar::Dependencies.subparse($file_content, :actions(Action::Dependencies.new)).made;
    $class.dependencies = $dependencies.flat if $dependencies;

    $log.debug($class.raku);

    return $class;
}