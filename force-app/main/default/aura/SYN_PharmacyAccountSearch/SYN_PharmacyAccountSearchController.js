({
    onInit: function( component, event, helper ) {
        debugger;
        // proactively search on component initialization
        var searchTerm = component.get( "v.searchTerm" );
        component.set("v.sortedBy",null);
         component.set("v.sortedDirection",null);
        //helper.handleSearch( component );
    },
    
    onSearchTermChange: function( component, event, helper ) {
       /* var firstName = component.find( "FirstName" );
        var LastName = component.find( "LastName" );
        var DOB = component.find( "DOB" );
        var Phone = component.find( "Phone" );
        var ZipCode = component.find( "zipcode" );*/
         var firstName = component.get( "v.FirstNameSearch" );
        var LastName = component.get( "v.LastNameSearch" );
        var DOB = component.get( "v.DOBSearch" );
        var Phone = component.get( "v.PhoneSearch" );
        var ZipCode = component.get( "v.ZipSearch" );
       // alert('firstName'+firstName+' '+(firstName == '' || firstName ==null));
        // alert('LastName'+LastName);
        // alert('DOB'+DOB);
        // alert('Phone'+Phone);
        // alert('ZipCode'+ZipCode);
          if((firstName == '' || firstName ==null) && (LastName == ''||LastName ==null) &&  (DOB == ''||DOB ==null) && (Phone == ''||Phone ==null ) && (ZipCode == ''||ZipCode ==null)){
           //alert('Please select any search term');
           helper.showToast(component, "error", "Please search with two identifiers to display Patient Results.", "",null,"dismissable"); 
          }else{
             var count=0;
              if((firstName != '' && firstName !=null)){
                  count=count+1;
              }
               if((LastName != '' && LastName !=null)){
                  count=count+1;
              }
              if((DOB != '' && DOB !=null)){
                  count=count+1;
              }
              if((Phone != '' && Phone !=null)){
                  count=count+1;
              }
              if((ZipCode != '' && ZipCode !=null)){
                  count=count+1;
              }
              //alert(count);
              if(count>=2){
              helper.handleSearch(component);
              }else{
                 helper.showToast(component, "error", "Please search with two identifiers to display Patient Results.", "",null,"dismissable"); 
              }
          }
    },
     onAccountsSorted: function( component, event, helper ) {
        // proactively search on component initialization
        debugger;
        var searchTerm = component.get( "v.searchTerm" );
         var sortingfield=event.getParam( 'SortingField' );
         var sortingDirection=event.getParam( 'SortingDirection' );
         component.set("v.sortedBy",sortingfield);
         component.set("v.sortedDirection",sortingDirection);
        // alert('SortingDirection '+component.get( "v.sortedDirection" ));
         helper.handleSearch( component );
    },
})