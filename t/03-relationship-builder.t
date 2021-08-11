use Test;
use lib './';

use RelationshipBuilder;

my $cut = RelationshipBuilder.new;

my %classes =
    classes => @(
        %(:attributes($[{:attribute("\$.view"), :type("")}, {:attribute("\$.renderer"), :type("")}, {:attribute("\$.atikon_api"), :type("")}, {:attribute("\$.otrs_api"), :type("")}, {:attribute("\$.webcontent_api"), :type("")}, {:attribute("\$.database"), :type("")}, {:attribute("\%.config"), :type("")}]), :implement($[]), :inheritance($[]), :name("MeinAtikon"), :methods($["routes", "authentication", "privacy-policy", "dashboard", "onboarding", "information", "domain", "contacts", "products", "webcontent", "tracking", "static", "get-information-business-logic"])),
        %(:attributes($[{:attribute("\$.cms_url"), :type("Str")}, {:attribute("\$.onlinetools_url"), :type("Str")}]), :implement($["MetadataProcessor"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon::BusinessLogic::Dashboard"), :methods($["get-panel-data", "get-newsletter-panel-data", "get-some-panel-data", "get-homepage-panel-data", "get-checklist-name", "get-checklist-entries", "update-checklist-entry", "confetti-shown"])),
        %(:attributes($[{:attribute("\$.cms_url"), :type("Str")}, {:attribute("\$.onlinetools_url"), :type("Str")}]), :implement($["MetadataProcessor"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon::Model::WebcontentAPI"), :methods($["get-panel-data", "get-newsletter-panel-data", "get-some-panel-data", "get-homepage-panel-data", "get-checklist-name", "get-checklist-entries", "update-checklist-entry", "confetti-shown"])),
        %(:implement($["CustomerFileAccess['Socialmedia-Screenshots']", "InputInflator", "MetadataProcessor", "StandardFileUpload"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon::BusinessLogic::Dashboard::Socialmedia"), :methods($["get-status-data", "screenshots", "model-letter"])),
        %(:attributes($[{:attribute("\$.cms_url"), :type("Str")}, {:attribute("\$.webcontent_api"), :type("MeinAtikon::Model::WebcontentAPI")}]), :implement($[]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon::BusinessLogic::Dashboard::Homepage"), :methods($["get-website-uri", "get-statistic-uri", "get-homepage-change-uri", "get-eigenwartung-uri", "get-documentation-uri"])),
    ),
;

my %actual = $cut.get-relationships(%classes);
is-deeply %actual<relationships>, ['MeinAtikon::BusinessLogic::Dashboard::Homepage' => ["MeinAtikon::Model::WebcontentAPI"]], 'Expected attributes string';
nok %actual<inheritance>, 'Expected Any for inheritance';

{
    my %classes =
        classes => @(
            {:implement($[]), :inheritance($[]), :name("MeinAtikon::BusinessLogic"), :methods($["get-somethin-total-important"])},
            {:implement($["CustomerFileAccess['Socialmedia-Screenshots']", "InputInflator", "MetadataProcessor", "StandardFileUpload"]), :inheritance($["MeinAtikon::BusinessLogic"]), :name("MeinAtikon::BusinessLogic::Dashboard::Socialmedia"), :methods($["get-status-data", "screenshots", "model-letter"])},
        ),
    ;
    my %actual = $cut.get-relationships(%classes);
    my $expected = ["MeinAtikon::BusinessLogic::Dashboard::Socialmedia" => ["MeinAtikon::BusinessLogic"]];
    is-deeply %actual<inheritance>, $expected, 'Expected inheritance string';
}
{
    my @actual = $cut.get-inheritance([], Set.new);
    is-deeply @actual, [], 'get-inheritance: without parameter empty array is returned';
}

{
    my @actual = $cut.get-relations([], Set.new);
    is-deeply @actual, [], 'Returns empty array with empty class array';

    @actual = $cut.get-relations([{name => 'name', attributes => []},], Set.new);
    is-deeply @actual, [], 'Returns empty array without class names';

    @actual = $cut.get-relations([{name => 'name', inheritance => []},], Set.new);
    is-deeply @actual, [], 'Returns empty array without attributes';

    @actual = $cut.get-relations([{name => 'class_name', attributes => [{attribute => 'attribute_name', type => 'Type'}]},], Set.new('Type'));
    is-deeply @actual, [{class_name => ['Type']}], 'Returns attribute with the same type';

    @actual = $cut.get-relations([{name => 'class_name', attributes => [{attribute => 'attribute_name', type => 'another_type'}]},], Set.new('Type'));
    is-deeply @actual, [], 'Returns empty array for wrong attribute type';
}

{
    my @actual = $cut.get-inheritance([], Set.new);
    is-deeply @actual, [], 'get-inheritance: Returns empty array with empty class array';

    @actual = $cut.get-inheritance([{name => 'name', inheritance => []},], Set.new);
    is-deeply @actual, [], 'get-inheritance: Returns empty array without class names';

    @actual = $cut.get-inheritance([{name => 'name'}], Set.new);
    is-deeply @actual, [], 'get-inheritance: Returns empty array without inheritance';

    @actual = $cut.get-inheritance([{name => 'class_name', inheritance => []}], Set.new);
    is-deeply @actual, [], 'get-inheritance: Returns empty array without any inheritance items';

    @actual = $cut.get-inheritance([{name => 'class_name', inheritance => ['inheritance_one']},], Set.new('inheritance_one'));
    is-deeply @actual, [{class_name => ['inheritance_one']}], 'get-inheritance: Returns inheritance';

    @actual = $cut.get-inheritance([{name => 'class_name', inheritance => ['inheritance_one']},], Set.new('inheritance_two'));
    is-deeply @actual, [], 'get-inheritance: Returns empty array for unknow type';
}

done-testing;