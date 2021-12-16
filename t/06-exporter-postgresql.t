use Test;
use Red;
use lib './lib';

use Exporter::PostgreSQL;

my $*RED-DEBUG = True;
red-defaults "Pg", :dbname("code_analysis_wb"), :host('server'), :user('postgres'), :password('nordpol');
# red-defaults "Pg", :dbname("code_analysis_wb"), :host('/var/run/postgresql');

my %packages_postgresql = %(
    MeinAtikon => [
        {
            name => 'Route',
            matcher => regex {'Route'},
        },
        {
            name => 'BusinessLogic',
            matcher => regex {'BusinessLogic'},
        },
        {
            name => 'Model',
            matcher => regex {'Model'},
        },
        {
            name => 'View',
            matcher => regex {'View'},
        },
        {
            name => 'Test',
            matcher => regex {'Test'},
        },
    ]
);

subtest 'get-classes', {
    my $cut = Exporter::PostgreSQL.new(packages => %packages_postgresql);
}

done-testing;
