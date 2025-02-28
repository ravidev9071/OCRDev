({
    onInit: function( component, event, helper ) {
        // proactively search on component initialization
         if(component.get("v.haveAccess")){
        var searchTerm = component.get( "v.searchTerm" );
        
       
        helper.handleSearch( component, searchTerm );
        component.set("v.sortedBy",'LastName');
        component.set("v.sortedDirection",'desc');
         }
    },
    doInit: function( component, event, helper ) {
        // proactively search on component initialization
       // alert('In do Int'+component.get("v.haveAccess"));
         if(component.get("v.haveAccess")){
        var searchTerm = component.get( "v.searchTerm" );
        
       
        helper.handleSearch( component, searchTerm );
        component.set("v.sortedBy",'LastName');
        component.set("v.sortedDirection",'desc');
         }
    },
    onChangeRadioValue: function( component, event, helper ) {
        // proactively search on component initialization
        var searchTerm = component.get( "v.searchTerm" );
        helper.handleSearch( component, searchTerm );
    },
    onSearchTermChange: function( component, event, helper ) {
        var selectedone = event.getSource().get("v.name");
        var firstName = component.get( "v.FirstNameSearch" );
        var LastName = component.get( "v.LastNameSearch" );
        var DOB = component.get( "v.DOBSearch" );
        var Phone = component.get( "v.PhoneSearch" );
        var ZipCode = component.get( "v.ZipSearch" );
        var searchTerm = component.get( "v.searchTerm" );


        
          if( selectedone =='SearchBtn' && (firstName == '' || firstName ==null) && (LastName == ''||LastName ==null) &&  (DOB == ''||DOB ==null) && (Phone == ''||Phone ==null ) && (ZipCode == ''||ZipCode ==null)){
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
            component.set("v.LoadRadioBtnRecs",false);
            component.set("v.LoadMYPatRadioBtnRecs",false);
            helper.handleSearch( component, searchTerm );
            }else{
            helper.showToast(component, "error", "Please search with two identifiers to display Patient Results.", "",null,"dismissable");
            }
            }
        
        
    },
    onSearchTermChangeRadioBtn: function( component, event, helper ) {
        var searchTerm = component.get( "v.searchTerm" );
        var radioValue = component.get("v.value");
        component.set( "v.FirstNameSearch","");
        component.set( "v.LastNameSearch","");
        component.set( "v.DOBSearch",'');
        component.set( "v.PhoneSearch",'' );
        component.set( "v.ZipSearch",'' );
        if(radioValue == 'mypatients'){
            component.set("v.LoadMYPatRadioBtnRecs",true); 
            component.set("v.LoadRadioBtnRecs",false);
            helper.handleSearch( component, searchTerm );
        }else if(radioValue == 'allpatients'){
            component.set("v.LoadRadioBtnRecs",true);
            component.set("v.LoadMYPatRadioBtnRecs",false);
            helper.handleSearch( component, searchTerm );
        }
        
    },
    onSearchTermChangeWhenNull: function( component, event, helper ) {
        var selectedone = event.getSource().get("v.name")
        var firstName = component.get( "v.FirstNameSearch" );
        var LastName = component.get( "v.LastNameSearch" );
        var DOB = component.get("v.DOBSearch");
        
       // var DOB = component.find("DOBfield").get("v.value");
        //var validity = component.find("DOBfield").get("v.validity");
        var Phone = component.get( "v.PhoneSearch" );
        var ZipCode = component.get( "v.ZipSearch" );
        var radioValue = component.get("v.value");
        //alert('DOB');
          if( selectedone !='SearchBtn' && (radioValue == 'mypatients' || radioValue == 'allpatients') && (firstName == '' || firstName ==null) && (LastName == ''||LastName ==null) && (DOB == '' || DOB == null) && (Phone == ''||Phone ==null ) && (ZipCode == ''||ZipCode ==null)){
          var searchTerm = component.get( "v.searchTerm" );
              component.set("v.LoadRadioBtnRecs",false);
              component.set("v.LoadMYPatRadioBtnRecs",false);
              helper.handleSearch( component, searchTerm );
          } 
    },

     onAccountsSorted: function( component, event, helper ) {
        // proactively search on component initialization
        debugger;
       // var searchTerm = component.get( "v.searchTerm" );
         var sortingfield=event.getParam( 'SortingField' );
         var sortingDirection=event.getParam( 'SortingDirection' );
         component.set("v.sortedBy",sortingfield);
         component.set("v.sortedDirection",sortingDirection);
    helper.sortData(component,sortingfield,sortingDirection);
        // alert('SortingDirection '+component.get( "v.sortedDirection" ));
        //helper.handleSearch( component, searchTerm );
    },
})