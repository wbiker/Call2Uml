use Test;
use File::Temp;
use lib './lib';

use Class2Uml;

my $cut = Class2Uml.new;

subtest 'fail when class name missing', {
    my ($temp, $file_handle) = tempfile;
    $file_handle.say("nothing here, go ahead");

    dies-ok {$cut.parse($temp.IO);} , 'returns Any when no class definitions found';
}

subtest 'attributes', {
    my @attributes_tests =
        { test => 'has $.attribute;', expected => {attribute => '$.attribute', type => ''}, output => 'attribute without traits' },
        { test => 'has Str $.attribute;', expected => {attribute => '$.attribute', type => 'Str'}, output => 'attribute with type' },
        { test => ' has $.attribute;', expected => {attribute => '$.attribute', type => ''}, output => 'attribute without traits and space' },
        { test => ' has Str $.attribute;', expected => {attribute => '$.attribute', type => 'Str'}, output => 'attribute with type and space' },
        { test => 'has $.attribute is rw;', expected => {attribute => '$.attribute', type => ''}, output => 'attribute with traits' },
        { test => 'has Str $.attribute is rw;', expected => {attribute => '$.attribute', type => 'Str'}, output => 'attribute with type and traits' },
        { test => 'has &.attribute;', expected => {attribute => '&.attribute', type => ''}, output => 'callable attribute' },
        { test => 'has &.attribute is rw;', expected => {attribute => '&.attribute', type => ''}, output => 'callable attribute with traits' },
        { test => 'has &.attribute is rw;', expected => {attribute => '&.attribute', type => ''}, output => 'callable attribute with traits' },
        { test => 'has Name::Space &.attribute;', expected => {attribute => '&.attribute', type => 'Name::Space'}, output => 'callable attribute with namespaces' },
    ;

    for @attributes_tests -> $test {
        my %data;
        $cut.parse-string(%data, $test<test>);

        my %expected = attributes => [ $test<expected> ];
        is-deeply %data, %expected, $test<output>;
    }
}

subtest 'methods', {
    my @method_tests =
        { test => 'method test() {', expected => 'test', output => 'method without variable' },
        { test => ' method test() {', expected => 'test', output => 'method with space' },
        { test => 'method test(Str $param) {', expected => 'test', output => 'method with parameter' },
        { test => 'method test {', expected => 'test', output => 'method without parenteses' },
        { test => 'method TOP($/) {', expected => 'TOP', output => 'Grammar TOP method' },
    ;

    for @method_tests -> $test {
        my %data;
        $cut.parse-string(%data, $test<test>);

        my %expected = methods => [ $test<expected> ];
        is-deeply %data, %expected, $test<output>;
    }
}


done-testing;
