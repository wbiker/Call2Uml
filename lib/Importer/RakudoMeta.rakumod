unit class Importer::RakudoMeta;

#(
    #rakudo -Ilib -e 'my $stash := $*REPO.load("NativeCall.rakumod".IO).handle.globalish-package; sub dump-stash($stash, :$parent) { for $stash.kv -> $name is copy, $package { $name = "{$parent}::$name" if $parent; if $package.HOW ~~ Metamodel::ClassHOW { say "    Attributes: {$package.^attributes}"; say "    Methods: {$package.^methods>>.name}" }; say $name; dump-stash($package.WHO, :parent($name)) } }; dump-stash($stash)'
#)

method import() {
    my $stash := $*REPO.load("Test/TestClass.rakumod".IO).handle.globalish-package;
    sub dump-stash($stash, :$parent) {
        for $stash.kv -> $name is copy, $package {
            $name = "{$parent}::$name" if $parent;
            if $package.HOW ~~ Metamodel::ClassHOW {
                say "    Attributes: {$package.^attributes}";
                say "    Methods: {$package.^methods>>.name}"
            };
                say $name; dump-stash($package.WHO, :parent($name))
        }
    };
    dump-stash($stash);

    # my $comp-unit := $*REPO.load("../../module2rpm/lib/module2rpm/Role/Archive.rakumod".IO);

    # dd $comp-unit;
    # my $handle = $comp-unit.handle;
    # dd $handle;
    # my $globalish-package = $handle.globalish-package;
    # dd $globalish-package;
    # for $globalish-package -> $pack {
    # for $pack.kv -> $i, $package {
    #     say $i, " ", $package;
    # }
    # }
}