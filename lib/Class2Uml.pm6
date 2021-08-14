use Cro::WebApp::Template;

use Grammar::Class;
use RakuClass;

unit class Class2Uml;

method parse(IO::Path $file) {
    my $file_content = $file.slurp;

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

    my $outcome = Grammar::Methods.subparse($file_content, :actions(Action::Methods.new)).made;
    $class.methods = $outcome.flat if $outcome;

    return $class;
}

method parse-string(%data, Str $line) {
    if $line ~~ /[^ | \s] 'has' \s ([\w | \:]+ \s+)? (['$'|'@'|'%'|'&']<-[;]>+)/ {
        my $type = $0 ?? ~$0 !! '';
        $type .= trim;
        my $attribute = ~$1;
        $attribute ~~ s:g/\s .*//;
        %data<attributes>.push: { :$attribute, :$type};
        return %data;
    }

    if $line ~~ /[^ | \s] 'method' \s+ (<-[( {]>+)/ {
        %data<methods>.push: ~$0.trim;
        return %data;
    }

    return %data;
}
