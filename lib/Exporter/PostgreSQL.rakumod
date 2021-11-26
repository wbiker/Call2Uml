use Red;

use RakuClass;

model Datasources {
    has Int $.id is serial;
    has Str $.name is column is rw;
}

model Systems {
    has Int $.id is serial;
    has Str $.name is column
}

model Modules {
    has Int $.id is serial;
    has Int $.system_id is referencing(*.id, :model(Systems));
    has Str $.namespace is column;
    has Bool $.is_class is column;
}

model ModuleConsumes {
    has Int $.module_id is referencing(*.id, :model<Modules>);
    has Int $.consumes_id is referencing(*.id, :model<Modules>);
    has $.consume_type is column;
}

model ModuleConsumesExternals {
    has $.module_id is referencing(*.id, :model<Modules>);
    has $.external_namespace is column;
    has $.consume_type is column;
    has Bool $.visible is column;
}

model ModuleConnectsTo {
    has Int $.module_id is referencing(*.id, :model<Modules>);
    has Int $.datasource_id is referencing(*.id, :model<Datasource>);
}

model Attributes {
    has Int $.id is serial;
    has Int $.module_id is referencing(*.id, :model<Modules>);
    has Str $.name is column;
}

model Subs {
    has Int $.id is serial;
    has Int $.module_id is referencing(*.id, :model<Modules>);
    has Str $.name is column;
    has Bool $.is_method is column;
}

# red-defaults "Pg", :host("/var/run/postgresql"), :dbname('code_analysis_wb');

class Exporter::PostgreSQL {
    has %classes_already_inserted;
    has %classes_by_name;

    method save(%classes) {

        my $system = Systems.^create(name => 'MeinAtikon');
        %!classes_by_name = %classes<classes>.flat.map({ $_.name => $_ });

        for %classes<classes>.flat -> $class {
            self.save-module($class, $system);
        }
    }

    method save-module(RakuClass $class, $system) {
        next if %classes_already_inserted{$class.name}:exists;

        my $module = Modules.^create(system_id => $system.id, namespace => $class.name, is_class => !$class.is-role);

        for $class.inheritances.flat -> $parent_name {
            if %classes_already_inserted{$parent_name}:exists {
                my $consumed_module = %classes_already_inserted{$parent_name};
                ModuleConsumes.^create(module_id => $module.id, consumes_id => $consumed_module.id, consume_type => 'extends');
            } else {
                my $parent_module = %classes_by_name{$parent_name};
                if $parent_module {
                    my $parent_module_db = self.save-module($parent_module, $system);
                    ModuleConsumes.^create(module_id => $module.id, consumes_id => $parent_module_db.id, consume_type => 'extends');
                } else {
                    ModuleConsumesExternals.^create(module_id => $module.id, external_namespace => $parent_name, consume_type => 'extends', visible => True);
                }
            }
        }

        for $class.implements.flat -> $implement {
            my $class = %!classes_by_name{$implement};
            if $class {
                my $parent_module_db = self.save-module($class, $system);
                ModuleConsumes.^create(module_id => $module.id, consumes_id => $parent_module_db.id, consume_type => 'with');
            } else {
                ModuleConsumesExternals.^create(module_id => $module.id, external_namespace => $implement, consume_type => 'with', visible => True);
            }
        }

        for $class.attributes.flat -> $attribute {
            Attributes.^create(module_id => $module.id, name => $attribute<name>);
        }

        for $class.methods.flat -> $method {
            Subs.^create(module_id => $module.id, name => $method.trim, is_method => True);
        }

        %classes_already_inserted{$class.name} = $module;

        return $module;
    }
}