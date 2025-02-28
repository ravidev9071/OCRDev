/**
 * @description       : this is the test class to cover for SYN_InvocableActionPerformer
 * @author            : Dileep Gurram
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public  class SYN_InvocableActionPerformer_Test {
    @isTest
    Static void TestPerformActionwithSkipCaseTrigger(){
        SYN_InvocableActionPerformer.ActionParameters testParam=new SYN_InvocableActionPerformer.ActionParameters();
        testParam.action='skipcaseTrigger';
        List<SYN_InvocableActionPerformer.ActionParameters> testParams=new  List<SYN_InvocableActionPerformer.ActionParameters>();
        testParams.Add(testParam);
        List<String> result = SYN_InvocableActionPerformer.performAction(testParams);
        System.assertEquals(null,result,'Result should be Null');
         System.assertEquals(True,SYN_SkipCaseTrigger.skipCaseTrigger,'skipCaseTrigger should be True');
        
    }
  @isTest
    Static void TestPerformActionwithinValidAction(){
        SYN_InvocableActionPerformer.ActionParameters testParam=new SYN_InvocableActionPerformer.ActionParameters();
        testParam.action='inValidAction';
        List<SYN_InvocableActionPerformer.ActionParameters> testParams=new  List<SYN_InvocableActionPerformer.ActionParameters>();
        testParams.Add(testParam);
        List<String> result=  SYN_InvocableActionPerformer.performAction(testParams);
        System.assertEquals(null,result,'Result should be Null');
         System.assertEquals(False,SYN_SkipCaseTrigger.skipCaseTrigger,'skipCaseTrigger should  not be Modified');
        
    }

}