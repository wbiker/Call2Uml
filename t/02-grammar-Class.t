use Test;
use lib './lib';

use Grammar::Class;

#my $test_string = '/home/wolf/tmp/raku_class_files/MeinAtikon/MeinAtikon.pm6'.IO.slurp;
#my $test_string = '/home/wolf/tmp/raku_class_files/MeinAtikon/BusinessLogic/Dashboard.pm6'.IO.slurp;
#my $test_string = '/home/wolf/tmp/raku_class_files/MeinAtikon/BusinessLogic/Dashboard/Socialmedia.pm6'.IO.slurp;
my $test_string = '/home/wolf/tmp/raku_class_files/MeinAtikon/BusinessLogic/Dashboard/Homepage.pm6'.IO.slurp;

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

my $actions = Action::ClassName.new;
{
    my $test = q:to/END/;
    need MeinAtikon::Model::WebcontentAPI;

    unit class MeinAtikon::BusinessLogic::Dashboard::Homepage is MeinAtikon::BusinessLogic;

    has Str $.cms_url is required;
    has MeinAtikon::Model::WebcontentAPI $.webcontent_api is required;
    END

    my $outcome = Grammar::ClassName.subparse($test, :$actions);
    my %actual = $outcome.made;
    is-deeply %actual, {implement => [], inheritance => ['MeinAtikon::BusinessLogic'],
                        name => 'MeinAtikon::BusinessLogic::Dashboard::Homepage'}, 'unit class without newline';
}
{
    my $test = q:to/END/;
    need MeinAtikon::Model::WebcontentAPI;

    unit class MeinAtikon::BusinessLogic::Dashboard::Homepage
        is MeinAtikon::BusinessLogic
        does MeinAtikon::ExeptionHandler;

    has Str $.cms_url is required;
    has MeinAtikon::Model::WebcontentAPI $.webcontent_api is required;
    END

    my $outcome = Grammar::ClassName.parse($test, :$actions);
    my %actual = $outcome.made;
    is-deeply %actual, {implement => ['MeinAtikon::ExeptionHandler'],
                        inheritance => ['MeinAtikon::BusinessLogic'], name => 'MeinAtikon::BusinessLogic::Dashboard::Homepage'}, 'unit class with newline';
}

done-testing;
