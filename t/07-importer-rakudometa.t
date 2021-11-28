use Test;
use lib './lib';

use Importer::RakudoMeta;

my $importer = Importer::RakudoMeta.new;
$importer.import;

done-testing;
