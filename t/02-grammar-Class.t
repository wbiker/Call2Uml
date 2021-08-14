use Test;
use lib './lib';

use Grammar::Class;

#my $test_string = '/home/wolf/tmp/raku_class_files/Name/Name.pm6'.IO.slurp;
#my $test_string = '/home/wolf/tmp/raku_class_files/Name/Space/Dashboard.pm6'.IO.slurp;
#my $test_string = '/home/wolf/tmp/raku_class_files/Name/Space/Dashboard/Socialmedia.pm6'.IO.slurp;
#my $test_string = '/home/wolf/tmp/raku_class_files/Name/Space/Dashboard/Homepage.pm6'.IO.slurp;

my @class_definitions =
    {test => 'unit class test;',
     expect_data => {:implement($[]), :inheritance($[]), :name("test")}},
    {test => 'unit class test is parent;',
     expect_data => {:implement($[]), :inheritance($['parent']), :name("test")}},
    {test => 'unit class test does role;',
     expect_data => {:implement($["role"]), :inheritance($[]), :name("test")}},
    {test => 'unit class test is parent does role;',
     expect_data => {:implement($["role"]), :inheritance($['parent']), :name("test")}},
    {test => 'unit class test is parent does role does secrole;',
     expect_data => {:implement($["role", 'secrole']), :inheritance($['parent']), :name("test")}},
    {test => 'unit class test does role does secrole;',
     expect_data => {:implement($["role", 'secrole']), :inheritance($[]), :name("test")}},
    {test => 'unit class name::space::test;',
     expect_data => {:implement($[]), :inheritance($[]), :name("name::space::test")}},
    {test => 'unit class name::space::test is parent;',
     expect_data => {:implement($[]), :inheritance($['parent']), :name("name::space::test")}},
    {test => 'unit class name::space::test does role;',
     expect_data => {:implement($["role"]), :inheritance($[]), :name("name::space::test")}},
    {test => 'unit class name::space::test is parent does role;',
     expect_data => {:implement($["role"]), :inheritance($['parent']), :name("name::space::test")}},
    {test => 'unit class name::space::test is parent does role does secrole;',
     expect_data => {:implement($["role", "secrole"]), :inheritance($['parent']), :name("name::space::test")}},
    {test => 'unit class name::space::test does role does secrole;',
     expect_data => {:implement($["role", "secrole"]), :inheritance($[]), :name("name::space::test")}},
    {test => 'class test {',
     expect_data => {:implement($[]), :inheritance($[]), :name("test")}},
    {test => 'class test is parent {',
     expect_data => {:implement($[]), :inheritance($['parent']), :name("test")}},
    {test => 'class test does role {',
     expect_data => {:implement($["role"]), :inheritance($[]), :name("test")}
    },
    {test => 'class test is parent does role {',
     expect_data => {:implement($["role"]), :inheritance($["parent"]), :name("test")}
    },
    {test => 'class test is parent does role does secrole {',
     expect_data => {:implement($["role", "secrole"]), :inheritance($["parent"]), :name("test")}},
    {test => 'class test does role does secrole {',
     expect_data => {:implement($["role", "secrole"]), :inheritance($[]), :name("test")}},
    {test => 'class name::space::test {',
     expect_data => {:implement($[]), :inheritance($[]), :name("name::space::test")}},
    {test => 'class name::space::test is parent {',
     expect_data => {:implement($[]), :inheritance($['parent']), :name("name::space::test")}},
    {test => 'class name::space::test does role {',
     expect_data => {:implement($["role"]), :inheritance($[]), :name("name::space::test")}},
    {test => 'class name::space::test is parent does role {',
     expect_data => {:implement($["role"]), :inheritance($['parent']), :name("name::space::test")}},
    {test => 'class name::space::test is parent does role does secrole {',
     expect_data => {:implement($["role", 'secrole']), :inheritance($["parent"]), :name("name::space::test")}},
    {test => 'class name::space::test does role does secrole {',
     expect_data => {implement => ['role', 'secrole'], inheritance => [], name => 'name::space::test' }},
;

for @class_definitions -> $test {
    my $class_data = Grammar::ClassName.parse($test<test>, :actions(Action::ClassName.new)).made;
    is-deeply $class_data, $test<expect_data>, $test<test>;
}

{
    my $test = q:to/END/;
    need Name::Model::WebcontentAPI;

    unit class Name::Space::Dashboard::Homepage is Name::Space;

    has Str $.cms_url is required;
    has Name::Model::WebcontentAPI $.webcontent_api is required;
    END

    my $outcome = Grammar::ClassName.subparse($test, :actions(Action::ClassName.new));
    my %actual = $outcome.made;
    is-deeply %actual, {implement => [], inheritance => ['Name::Space'],
                        name => 'Name::Space::Dashboard::Homepage'}, 'unit class without newline';
}
{
    my $test = q:to/END/;
    need Name::Model::WebcontentAPI;

    unit class Name::Space::Dashboard::Homepage
        is Name::Space
        does Name::ExeptionHandler;

    has Str $.cms_url is required;
    has Name::Model::WebcontentAPI $.webcontent_api is required;
    END

    my $outcome = Grammar::ClassName.parse($test, :actions(Action::ClassName.new));
    my %actual = $outcome.made;
    is-deeply %actual, {implement => ['Name::ExeptionHandler'],
                        inheritance => ['Name::Space'], name => 'Name::Space::Dashboard::Homepage'}, 'unit class with newline';
}

subtest 'attributes', {
    {
        my $test = q:to/END/;
        need Name::Space::Class;

        has Str $.url is required;
        has Name::Space::Class $.api;
        END

        my $outcome = Grammar::Attributes.subparse($test, :actions(Action::Attributes.new));
        my @actual = $outcome.made;
        is-deeply @actual, [{:modifier("is required"), :name("\$.url"), :type("Str")},
                            {:modifier(''), :name("\$.api"), :type("Name::Space::Class")}],
                            'expected data structure for attributes';
    }
    {
        my $test = q:to/END/;
            class name {
            has Str $.url is required;
            has $.api;

            method test() {}
            END

        my $outcome = Grammar::Attributes.subparse($test, :actions(Action::Attributes.new));
        my @actual = $outcome.made;
        is-deeply @actual, [{:modifier("is required"), :name("\$.url"), :type("Str")},
                            {:modifier(''), :name("\$.api"), :type("")}],
            'expected data structure for attributes without type';
    }
    {
        my $test = q:to/END/;
            class name {
            has Str $.url is required;
            has $.api;
            has @!array;

            method test() {}
            END

        my $outcome = Grammar::Attributes.subparse($test, :actions(Action::Attributes.new));
        my @actual = $outcome.made;
        is-deeply @actual, [{:modifier("is required"), :name("\$.url"), :type("Str")},
                            {:modifier(''), :name("\$.api"), :type("")},
                            {:modifier(''), :name("\@!array"), :type("")}],
            'expected data structure for attributes without type';
    }
    {
        my $test = q:to/END/;
        need MeinAtikon::BusinessLogic;
        need MeinAtikon::Model::WebcontentAPI;

        unit class MeinAtikon::BusinessLogic::Dashboard::Homepage is MeinAtikon::BusinessLogic;

        has Str $.cms_url is required;
        has MeinAtikon::Model::WebcontentAPI $.webcontent_api is required;

        method get-website-uri(--> Str) {
            my $domain = $*user.domain // '';
            return "https://www.{$domain}";
        }
        END

        my $outcome = Grammar::Attributes.subparse($test, :actions(Action::Attributes.new));
        my @actual = $outcome.made;
            is-deeply @actual, [{:modifier("is required"), :name("\$.cms_url"), :type("Str")},
                                {:modifier('is required'), :name("\$.webcontent_api"), :type("MeinAtikon::Model::WebcontentAPI")}],
                'expected data structure for attributes without type';
    }
}

subtest 'dependencies', {
    my $content = q:to/END/;
need Name::Space;

need Name::Role::CustomerFileAccess;
need Name::Role::InputInflator;
need Name::Role::MetadataProcessor;
need Name::Role::StandardFileUpload;

unit class Name::Space::Dashboard::Socialmedia is Name::Space
    does CustomerFileAccess['Socialmedia-Screenshots']
    does InputInflator
    does MetadataProcessor
    does StandardFileUpload;

use Name::Model::SocialmediaScreenshot;
use Name::Model::SocialmediaModelLetter;
END

    my @expected =
        'Name::Space',
        'Name::Role::CustomerFileAccess',
        'Name::Role::InputInflator',
        'Name::Role::MetadataProcessor',
        'Name::Role::StandardFileUpload',
        'Name::Model::SocialmediaScreenshot',
        'Name::Model::SocialmediaModelLetter';

    my $result = Grammar::Dependencies.subparse($content);
    is-deeply $result<dependency>.map(*<name>.Str).Array, @expected, 'expected dependencies';
}

done-testing;
