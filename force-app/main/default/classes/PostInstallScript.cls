global with sharing class PostInstallScript implements InstallHandler {

    global void onInstall(InstallContext context) {
        //New Install
        if(context.previousVersion() == null) {
            Case caso = new Case();
            String description = 'context.previousVersion() -> '+ String.valueOf(context.previousVersion());
            description += '\ncontext.isUpgrade() -> '+ String.valueOf(context.isUpgrade());
            description += '\ncontext.isPush() -> '+ String.valueOf(context.isPush());
            description += '\nUser() -> '+ UserInfo.getName();
            description += '\nInstallerId() -> '+ context.installerId();
            caso.Description = description;
            insert caso;
        } else {
            if(context.previousVersion().compareTo( new Version(1,0) ) == 0) {
                //Upgrade
                insert new Lead(Company = String.valueOf(context.isUpgrade()), LastName = context.installerId(), Status = 'Open');
            }
        }
    }
}
  
