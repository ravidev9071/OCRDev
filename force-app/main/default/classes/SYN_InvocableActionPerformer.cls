/**

 * @description       : this class is used to skipthe acse trigger by assigning boolean value to true once it is invoked form flow
 * @author            : Dileep gurram
 * @group             : 
 * @last modified on  : 11-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SYN_InvocableActionPerformer {
   @InvocableMethod(label='Perform Action')
    public static list<String> performAction(List<Actionparameters> params){
        switch on params[0].action{
            when 'skipcaseTrigger'{
                SYN_SkipCaseTrigger.skipCaseTrigger = true;
            }
        }
      return null;  
    }
    public class ActionParameters{
        @InvocableVariable
        Public String action;
        
    }

}