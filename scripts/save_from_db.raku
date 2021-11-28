use Red:api<2>;

use Exporter::PostgreSQL;

# red-defaults "Pg", :dbname("code_analysis_wb"), :host('/var/run/postgresql');
red-defaults "Pg", :dbname("code_analysis_wb"), :host('server'), :user('postgres'), :password('nordpol');

say $_.module_id for ModuleConsumes.^all;