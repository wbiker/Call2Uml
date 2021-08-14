use Test;
use lib './';

use RakuClass;
use RelationshipBuilder;

my $cut = RelationshipBuilder.new;

my %classes =
    classes => @(
        RakuClass.new(
            :name("MeinAtikon"),
            :attributes([{:name("\$.view"), :type("")},
                          {:name("\$.renderer"), :type("")},
                          {:name("\$.atikon_api"), :type("")},
                          {:name("\$.otrs_api"), :type("")},
                          {:name("\$.webcontent_api"), :type("")},
                          {:name("\$.database"), :type("")},
                          {:name("\%.config"), :type("")}])),
        RakuClass.new(
            :name("MeinAtikon::BusinessLogic::Dashboard"),
            :attributes([{:attribute("\$.cms_url"), :type("Str")},
                          {:attribute("\$.onlinetools_url"), :type("Str")}])),
        RakuClass.new(
            :name("MeinAtikon::Model::WebcontentAPI"),
            :attributes([{:name("\$.cms_url"), :type("Str")},
                          {:name("\$.onlinetools_url"), :type("Str")}])),
        RakuClass.new(
            :name("MeinAtikon::BusinessLogic::Dashboard::Socialmedia")),
        RakuClass.new(
            :name("MeinAtikon::BusinessLogic::Dashboard::Homepage"),
            :attributes([{:name("\$.cms_url"), :type("Str")},
                          {:name("\$.webcontent_api"), :type("MeinAtikon::Model::WebcontentAPI")}])),
    ),
;

my %actual = $cut.get-relationships(%classes);
is-deeply %actual<relationships>, ['MeinAtikon::BusinessLogic::Dashboard::Homepage' => ["MeinAtikon::Model::WebcontentAPI"]], 'Expected attributes string';
nok %actual<inheritance>, 'Expected Any for inheritance';

{
    my %classes =
        classes => [
            RakuClass.new(
                :name("MeinAtikon::BusinessLogic"),
                :methods(["get-somethin-total-important"])),
            RakuClass.new(
                :name("MeinAtikon::BusinessLogic::Dashboard::Socialmedia"),
                :implements(["CustomerFileAccess['Socialmedia-Screenshots']", "InputInflator", "MetadataProcessor", "StandardFileUpload"]),
                :inheritances(["MeinAtikon::BusinessLogic"]),
                :methods(["get-status-data", "screenshots", "model-letter"])),
        ]
    ;
    my %actual = $cut.get-relationships(%classes);
    my $expected = ["MeinAtikon::BusinessLogic::Dashboard::Socialmedia" => ["MeinAtikon::BusinessLogic"]];
    is-deeply %actual<inheritance>, $expected, 'Expected inheritance string';
}
{
    my @actual = $cut.get-inheritance([], Set.new);
    is-deeply @actual, [], 'get-inheritance: without parameter empty array is returned';
}

{
    my @actual = $cut.get-relations([], Set.new);
    is-deeply @actual, [], 'Returns empty array with empty class array';

    my $raku-class = RakuClass.new;
    @actual = $cut.get-relations([$raku-class], Set.new);
    is-deeply @actual, [], 'Returns empty array without class names';

    $raku-class = RakuClass.new(name => 'class_name', attributes => [{name => 'attribute_name', type => 'Type'}]);
    @actual = $cut.get-relations([$raku-class], Set.new('Type'));
    is-deeply @actual, [{class_name => ['Type']}], 'Returns attribute with the same type';

    $raku-class = RakuClass.new(name => 'class_name', attributes => [{name => 'attribute_name', type => 'another_type'}]);
    @actual = $cut.get-relations([$raku-class], Set.new('Type'));
    is-deeply @actual, [], 'Returns empty array for wrong attribute type';
}

{
    my @actual = $cut.get-inheritance([], Set.new);
    is-deeply @actual, [], 'get-inheritance: Returns empty array with empty class array';

    my $raku-class = RakuClass.new(name => 'name');
    @actual = $cut.get-inheritance([$raku-class], Set.new);
    is-deeply @actual, [], 'get-inheritance: Returns empty array without class names';

    $raku-class = RakuClass.new(name => 'class_name', inheritances => ['inheritance_one']);
    @actual = $cut.get-inheritance([$raku-class], Set.new('inheritance_one'));
    is-deeply @actual, [{class_name => ['inheritance_one']}], 'get-inheritance: Returns inheritance';

    @actual = $cut.get-inheritance([$raku-class], Set.new('inheritance_two'));
    is-deeply @actual, [], 'get-inheritance: Returns empty array for unknow type';
}

done-testing;