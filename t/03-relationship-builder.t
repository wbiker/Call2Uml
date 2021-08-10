use Test;
use lib './';

use RelationshipBuilder;

my $cut = RelationshipBuilder.new;

my %classes =
    classes => @(
        %(:attributes($[{:attribute("\$.view"), :type("")}, {:attribute("\$.renderer"), :type("")}, {:attribute("\$.atikon_api"), :type("")}, {:attribute("\$.otrs_api"), :type("")}, {:attribute("\$.webcontent_api"), :type("")}, {:attribute("\$.database"), :type("")}, {:attribute("\%.config"), :type("")}]), :definition(${:implement($[]), :inheritance($[]), :name("MeinAtikon")}), :methods($["routes", "authentication", "privacy-policy", "dashboard", "onboarding", "information", "domain", "contacts", "products", "webcontent", "tracking", "static", "get-information-business-logic"])),
        %(:attributes($[{:attribute("\$.cms_url"), :type("Str")}, {:attribute("\$.onlinetools_url"), :type("Str")}]), :definition(${:implement($["MetadataProcessor"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon_BusinessLogic_Dashboard")}), :methods($["get-panel-data", "get-newsletter-panel-data", "get-some-panel-data", "get-homepage-panel-data", "get-checklist-name", "get-checklist-entries", "update-checklist-entry", "confetti-shown"])),
        %(:attributes($[{:attribute("\$.cms_url"), :type("Str")}, {:attribute("\$.onlinetools_url"), :type("Str")}]), :definition(${:implement($["MetadataProcessor"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon_Model_WebcontentAPI")}), :methods($["get-panel-data", "get-newsletter-panel-data", "get-some-panel-data", "get-homepage-panel-data", "get-checklist-name", "get-checklist-entries", "update-checklist-entry", "confetti-shown"])),
        %(:definition(${:implement($["CustomerFileAccess['Socialmedia-Screenshots']", "InputInflator", "MetadataProcessor", "StandardFileUpload"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon_BusinessLogic_Dashboard_Socialmedia")}), :methods($["get-status-data", "screenshots", "model-letter"])),
        %(:attributes($[{:attribute("\$.cms_url"), :type("Str")}, {:attribute("\$.webcontent_api"), :type("MeinAtikon::Model::WebcontentAPI")}]), :definition(${:implement($[]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon_BusinessLogic_Dashboard_Homepage")}), :methods($["get-website-uri", "get-statistic-uri", "get-homepage-change-uri", "get-eigenwartung-uri", "get-documentation-uri"])),
    ),
;

my %actual = $cut.get-relationships(%classes);
is-deeply %actual<relationships>, ["MeinAtikon_BusinessLogic_Dashboard_Homepage o-- MeinAtikon_Model_WebcontentAPI : Aggregation"], 'Expected attributes string';
nok %actual<inheritance>, 'Expected Any for inheritance';

{
    my %classes =
        classes => @(
            %({:definition(${:implement($[]), :inheritance($[]), :name("MeinAtikon_BusinessLogic")}), :methods($["get-somethin-total-important"])}),
            %(:definition(${:implement($["CustomerFileAccess['Socialmedia-Screenshots']", "InputInflator", "MetadataProcessor", "StandardFileUpload"]), :inheritance($["MeinAtikon_BusinessLogic"]), :name("MeinAtikon_BusinessLogic_Dashboard_Socialmedia")}), :methods($["get-status-data", "screenshots", "model-letter"])),
        ),
    ;

    my %actual = $cut.get-relationships(%classes);
    is-deeply %actual<inheritance>, ["MeinAtikon_BusinessLogic_Dashboard_Socialmedia --|> MeinAtikon_BusinessLogic"], 'Expected inheritance string';
}
{
    my @actual = $cut.get-inheritance([], []);
    is-deeply @actual, [], 'get-inheritance: without parameter empty array is returned';
}

done-testing;