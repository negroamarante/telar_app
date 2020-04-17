@isTest
public with sharing class PostInstallScriptTest {
   
    @IsTest
    static void testInstallScript() {
        Account a = new Account(name='myAccount');
        insert a;
        Test.setCreatedDate(a.Id, DateTime.newInstance(2012,12,12));


        PostInstallScript postinstall = new PostInstallScript();
        // Test.testInstall(postinstall, null);
        System.debug('Test123');
        Test.testInstall(postinstall, new Version(2,1,2), true);

    }
}