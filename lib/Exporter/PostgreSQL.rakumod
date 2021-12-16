use Red;
use Logger;

use RakuClass;

model Datasources {
    has Int $.id is serial;
    has Str $.name is column is rw;
}

model Systems {
    has Int $.id is serial;
    has Str $.name is column
}

model Packages {
    has Int $.id is serial;
    has Int $.system_id is referencing(*.id, :model(Systems));
    has Str $.name is column;
    has Int $.sort_id is column;
}

model Modules {
    has Int $.id is serial;
    has Int $.system_id is referencing(*.id, :model(Systems));
    has Str $.namespace is column;
    has $.module_type is column;
    has Int $.package_id is referencing(*.id, :model(Packages));
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
    has Str $.isa is column;
    has Int $.creates_id is referencing(*.id, :model<Modules>);
}

model Subs {
    has Int $.id is serial;
    has Int $.module_id is referencing(*.id, :model<Modules>);
    has Str $.name is column;
    has $.sub_type is column;
}

model SubParameters {
    has Int $.id is serial;
    has Int $.sub_id is referencing(*.id, :model<Subs>);
    has Str $.name is column;
}

model SubCreates {
    has Int $.id is serial;
    has Int $.sub_id is referencing(*.id, :model<Subs>);
    has Int $.module_id is referencing(*.id, :model<Models>);
}

class Exporter::PostgreSQL {
    has %.packages is required;
    has $!log = Logger.get;

    has %classes_already_inserted;
    has %packages_already_inserted;
    has %classes_by_name;

    method save(%classes) {
        my $system = Systems.^create(name => 'MeinAtikon');
        %!classes_by_name = %classes<classes>.flat.map({ $_.name => $_ });

        for %classes<classes>.flat -> $class {
            self.save-module($class, $system);
        }
    }

    method save-module(RakuClass $class, $system) {
        return %!classes_already_inserted{$class.name} if %!classes_already_inserted{$class.name}:exists;

        my $package = self.save-package($class, $system.id);
        my $module = Modules.^create(system_id => $system.id, namespace => $class.name, is_class => !$class.is-role, package_id => $package.id);

        for $class.inheritances.flat -> $parent_name {
            if %!classes_already_inserted{$parent_name}:exists {
                my $consumed_module = %!classes_already_inserted{$parent_name};
                ModuleConsumes.^create(module_id => $module.id, consumes_id => $consumed_module.id, consume_type => 'extends');
            } else {
                my $parent_module = %!classes_by_name{$parent_name};
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

        for $class.dependencies.flat -> $dependency {
            my $class = %!classes_by_name{$dependency};
            if $class {
                my $parent_module_db = self.save-module($class, $system);
                ModuleConsumes.^create(module_id => $module.id, consumes_id => $parent_module_db.id, consume_type => 'use');
            } else {
                ModuleConsumesExternals.^create(module_id => $module.id, external_namespace => $dependency, consume_type => 'use', visible => True);
            }
        }

        for $class.attributes.flat -> $attribute {
            Attributes.^create(module_id => $module.id, name => $attribute<name>);
        }

        for $class.methods.flat -> $method {
            Subs.^create(module_id => $module.id, name => $method.trim, is_method => True);
        }

        %!classes_already_inserted{$class.name} = $module;

        return $module;
    }

    method save-package($class, $system_id) {
        state $sort_id = 1;

        for %!packages<MeinAtikon>.flat -> $package_info {
            my $name = $package_info<name>;
            my $matcher = $package_info<matcher>;
            if $class.name ~~ /<$matcher>/ {
                if %!packages_already_inserted{$package_info<name>}:exists {
                    return %!packages_already_inserted{$name};
                }

                my $package = Packages.^create(name => $name, system_id => $system_id, sort_id => $sort_id);
                ++$sort_id;
                %!packages_already_inserted{$name} = $package;
                return $package;
            }
        }

        $!log.debug("save-package: No package for {$class.name}");
        if %!packages_already_inserted<default>:exists {
            return %!packages_already_inserted<default>;
        }

        my $default_package = Packages.^create(name => 'default', system_id => $system_id, sort_id => $sort_id);
        ++$sort_id;
        %!packages_already_inserted<default> = $default_package;
        return $default_package;
    }
}