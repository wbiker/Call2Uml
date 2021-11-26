use Test;
use Red;
use lib './lib';

use Exporter::PostgreSQL;

my $*RED-DEBUG = True;
red-defaults "Pg", :dbname("code_analysis_wb"), :host('/var/run/postgresql');

subtest 'get-classes', {
    my $cut = Exporter::PostgreSQL.new;
    $cut.write;
}

done-testing;
