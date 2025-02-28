'undefined'===typeof Aura&&(Aura={});
(function() { 
	 function initAccessResources() {
			 $A.componentService.addModule('markup://force:customPerms', 'force/customPerms', ['exports'], null, {}); 
			 $A.componentService.addModule('markup://force:userPerms', 'force/userPerms', ['exports'], null, {UseWebLink: true,EmailAdministration: true,EmailTemplateManagement: true,EnableNotifications: true,AddDirectMessageMembers: true,PasswordNeverExpires: true,AllowUniversalSearch: true,ShowCompanyNameAsUserBadge: true,ActivitiesAccess: true,ContentWorkspaces: true,SelectFilesFromSalesforce: true,EnableCommunityAppLauncher: true,}); 
	 };
	 if(Aura.frameworkJsReady)initAccessResources();else{Aura.beforeFrameworkInit=Aura.beforeFrameworkInit||[],Aura.beforeFrameworkInit.push(initAccessResources)}
})(); 
Aura.StaticResourceMap = {"customListBox":{"remsdev2":1694691917000},"SNA_Patient_Enrollment1_sf_default_cdn_87xtj":{"remsdev2":1702303402000},"Download_Icon":{"remsdev2":1705929173000},"reactSignatureCanvas":{"remsdev2":1695290234000},"SNA_REMS_Digital1_sf_default_cdn_u3tlb":{"remsdev2":1706727733000},"PhUser":{"remsdev2":1678699320000},"REMSImages":{"remsdev2":1696324792000},"FixExtendedDatatable":{"sflabs_cms_ct":1704814826000},"papa_parse_5_0_2":{"remsdev2":1677768543000},"Patient":{"remsdev2":1678699320000},"PersonIcon2":{"remsdev2":1678699320000},"REMSVeevaAuthJSON":{"remsdev2":1693754563000},"signaturePad":{"remsdev2":1695404766000},"avtarimage":{"remsdev2":1678959134000},"siteAsset_9c65e02769a74c049f2f0733bb823274":{"remsdev2":1705255339000},"PersonIcon":{"remsdev2":1678699320000},"siteAsset_557293a047784bc6833a230085448cfc":{"remsdev2":1705258759000},"REMSAssets":{"remsdev2":1696324793000},"REMSVeevaSearchJSON":{"remsdev2":1693754798000},"siteAsset_8e4a58e131e74ff1a5c7629bdf2e91e7":{"remsdev2":1704733674000},"SiteSamples":{"remsdev2":1695421756000},"FAQ_Icon":{"remsdev2":1705929173000},"REMS":{"remsdev2":1692614918000}};

(function() {
function initResourceGVP() {
if (!$A.getContext() || !$A.get('$Resource')) {
$A.addValueProvider('$Resource',
{
merge : function() {},
isStorable : function() { return false; },
get : function(resource) {
var modStamp, rel, abs, name, ns;
var nsDelim = resource.indexOf('__');
if (nsDelim >= 0) { ns = resource.substring(0, nsDelim); name = resource.substring(nsDelim + 2); } else { name = resource; }
var srMap = Aura.StaticResourceMap[name];
modStamp = srMap && srMap[ns = ns || Object.keys(srMap)[0]];
if (!modStamp) { return; }
rel = $A.get('$SfdcSite.pathPrefix');
abs = $A.get('$Absolute.url');
return [(abs || rel || ''), '/resource/', modStamp, '/', ns === '' ? name : ns + '__' + name].join('');
}
});
}
}
if(Aura.frameworkJsReady)initResourceGVP();else{Aura.beforeFrameworkInit=Aura.beforeFrameworkInit||[],Aura.beforeFrameworkInit.push(initResourceGVP)}
})();