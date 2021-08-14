use Test;
use File::Temp;
use lib './lib';

use Exporter::Pod;
use RakuClass;

my %classes =
    classes => [
        RakuClass.new(name => 'class::name'),
    ]
;

subtest 'get-classes', {
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        my @actual = $cut.get-classes({});
        is-deeply @actual, [], 'Returns empty array for no classes';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        my @actual = $cut.get-classes(%classes);
        is-deeply @actual, [RakuClass.new(name => 'class_name')], ':: are replaced Class Name';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        %classes<classes>[0]<attributes>.push: { type => 'Name::Space::ClassName', };

        my @actual = $cut.get-classes(%classes);
        is-deeply @actual, [{ name => 'class_name', attributes => [{ type => 'Name_Space_ClassName' },] },],
        ':: are replaced Attribute Type';
    }
}

subtest 'get-inheritance', {
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        my @actual = $cut.get-inheritance({});
        is-deeply @actual, [], 'Returns empty array for no inheritances';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        %classes<inheritance>.push: 'Name::Space::ClassName' => 'Name::Space::Parent';

        my @actual = $cut.get-inheritance(%classes);
        is-deeply @actual, ['Name_Space_Parent <|-- Name_Space_ClassName'], ':: are replaced and inheritances are formatted';
    }
}

subtest 'get-relations', {
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        my @actual = $cut.get-relations({});
        is-deeply @actual, [], 'Returns empty array for no relations';
    }
    {
        my ($temp-file) = tempfile;
        my $cut = Exporter::Pod.new(file-path => $temp-file.IO);

        %classes<relationships>.push: 'Name::Space::ClassName' => 'Name::Space::Parent';

        my @actual = $cut.get-relations(%classes);
        is-deeply @actual, ['Name_Space_ClassName --o Name_Space_Parent : Aggregation'], ':: are replaced and relations are formatted';
    }
}

done-testing;
