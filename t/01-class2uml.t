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

done-testing;
