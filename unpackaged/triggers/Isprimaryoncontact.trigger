trigger Isprimaryoncontact on Contact (after insert , after update ) 
{
  // contacts will be having id,accountid , so adding to their respective id 
Set<Id> accountIdSet= new Set<Id>();
Set<Id> contactIdSet=new Set<Id>();
List<Account> updateAccList=new List<Account>();
List<Contact>Cnttoupdate=new List<Contact>();
        
            for(Contact contact:Trigger.new)
            {
                accountIdSet.add(contact.accountId);
                contactIdSet.add(contact.Id);
            }
            // Get accounts with their contacts.
 Map<Id,Account> accountMap=new Map<Id,Account>([select id, Phone,(select id, Name from Contacts where Is_Primary__c=true and 
                                                               id not in :contactIdSet) from Account where Id in: accountIdSet]); 
 Map<Id,contact>cntMap=new Map<Id,Contact>();
 
for(Account acc: accountMap.values()){
    for(Contact con : acc.contacts){
        cntMap.put(con.Id,con);

    }   

}   
    system.debug(cntMap);                                                                      
   // checking the data     
    boolean one_primary_found=false;
    for(Contact con:Trigger.new)
    {
        
        if(con.Is_Primary__c && accountMap.containsKey(con.accountId) && !one_primary_found)
        {	
            one_primary_found=true;
            Account ac=accountMap.get(con.AccountId); 
            for(Contact existing_cnt : ac.contacts){
                if(con.Id==null || (con.Id!=null && con.Id!=existing_cnt.Id)){
                    existing_cnt.Is_Primary__c=false;
                    cnttoupdate.add(existing_cnt);
                }
            }	                   
            ac.Phone=con.Phone;    
            updateAccList.add(ac);
        }
        else{
            con.adderror('Error ! Cannot add another primary account');
        }
    }
    if(!cnttoupdate.isEmpty()){
        update cnttoupdate;
    }
    if(!updateAccList.isEmpty()){   
        update updateAccList;
        
    }
}