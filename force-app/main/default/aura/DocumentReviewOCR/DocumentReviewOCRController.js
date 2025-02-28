({
    doInit: function (component, event, helper) {
        helper.initHelper(component, event);

    },
    iframeLoad: function (component, event, helper) {
        component.set("v.privewScreenspinner", false);
    },
})