public without sharing class RenderPDFController {

    // public RenderPDFController() { }

    // public String getBody() {
    //     return RenderEmailTemplateService.getHtml(TemplateID, WhoID, WhatID);
    // }

    // private String TemplateID {
    //     get {

    //         String templateDeveloperName = ApexPages.currentPage().getParameters().get('templateDeveloperName');

    //         if (String.isNotBlank(templateDeveloperName)) {
    //             return EmailTemplateUtil.getTemplateID(templateDeveloperName);
    //         }

    //         return ApexPages.currentPage().getParameters().get('templateId');
    //     }
    // }

    // private String WhoID {
    //     get {
    //         return ApexPages.currentPage().getParameters().get('whoId');
    //     }
    // }

    // private String WhatID {
    //     get {
    //         return ApexPages.currentPage().getParameters().get('whatId');
    //     }
    // }

    // public static String getUrl(Id templateID, Id whoID, Id whatID) {
    //     List<Object> args = new List<Object> { TwilioSettings.TwilioSiteUrl, templateID, whoID, whatID};
    //     return String.format('{0}/apex/RenderPDFHandler?templateId={1}&whoId={2}&whatId={3}', args);
    // }
}