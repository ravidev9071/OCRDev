public class SentFaxWrapper{


    public List<Destinations> destinations;
    public Fax_options fax_options;
    public Client_data client_data;
    public List<Documents> documents;
    public Oauth_response oauth_response;
    
    public class Oauth_response{
        public string access_token;
        public string  token_type;
        public string expires_in;
        public string scope;
        public string jti;
    }
    public class Retry_options {
        public Integer non_billable;
        public Integer billable;
        public Integer human_answer;
    }

    public class Client_data {
        public String client_code;
        public String client_id;
        public String client_matter;
        public String client_name;
        public String client_reference_id;
        public String billing_code;
    }

    public class Documents {
        public String document_type;
        public String document_content;
    }

    public class Destinations {
        public String to_name;
        public String to_company;
        public String fax_number;
    }

    public class Fax_options {
        public String image_resolution;
        public Boolean include_cover_page;
        public Cover_page_options cover_page_options;
        public Retry_options retry_options;
    }

    public class Cover_page_options {
        public String from_name;
        public String subject;
        public String message;
    }

    
    
}