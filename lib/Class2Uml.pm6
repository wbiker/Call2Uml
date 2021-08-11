use Cro::WebApp::Template;

use Grammar::Class;

unit class Class2Uml;

method parse(IO::Path $file) {
    my $file_content = $file.slurp;

    my $class_data = Grammar::ClassName.parse($file_content, :actions(Action::ClassName.new)).made;
    without $class_data {
       die "Could not find name in file '$file'";
    }

    my %file_data;
    %file_data.append($class_data.Hash);

    for $file_content.split("\n") -> $line {
        %file_data = self.parse-string(%file_data, $line);
    }

    return %file_data;
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
