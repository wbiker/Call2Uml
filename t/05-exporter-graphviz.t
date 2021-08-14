use Test;
use File::Temp;
use lib './lib';

use Exporter::Graphviz;
use RakuClass;

my %classes =
    classes => [
        RakuClass.new(name => 'class::name'),
    ]
;

subtest 'get-classes', {
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        my @actual = $cut.get-classes({});
        is-deeply @actual, [], 'Returns empty array for no classes';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        my @actual = $cut.get-classes(%classes);
        is-deeply @actual, [{ label => 'class::name||', name => 'class_name' },], 'No attributes and methods';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        %classes<classes>[0].attributes.push: { type => 'Name::Space::TypeName', name => 'attribute_name' };

        my @actual = $cut.get-classes(%classes);
        is-deeply @actual, [{:label("class::name|attribute_name : Name::Space::TypeName\\l|"), :name("class_name")},],
        ':: are replaced Attribute Type';
    }
}

subtest 'get-inheritance', {
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        my @actual = $cut.get-inheritance({});
        is-deeply @actual, [], 'Returns empty array for no inheritances';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        %classes<classes>[0].name = 'Name::Space::ClassName';
        %classes<classes>[0].inheritances.push: 'Name::Space::Parent';

        my @actual = $cut.get-inheritance(%classes);
        is-deeply @actual, ['Name_Space_Parent -> Name_Space_ClassName [dir=back]'], ':: are replaced and inheritances are formatted';
    }
}

subtest 'get-relations', {
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        my @actual = $cut.get-relations({});
        is-deeply @actual, [], 'Returns empty array for no relations';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Graphviz.new(file-path => $temp-file.IO);

        %classes<relationships>.push: 'Name::Space::ClassName' => 'Name::Space::Parent';

        my @actual = $cut.get-relations(%classes);
        is-deeply @actual, ['Name_Space_Parent -> Name_Space_ClassName [dir=back]'], ':: are replaced and relations are formatted';
    }
}

done-testing;
