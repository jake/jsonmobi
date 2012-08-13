var Mobi = {
    validate_json: function()
    {
        if (Mobi.JSON.valid($('#json').val())) {
            $('#json_wrapper').removeClass('warning');
        } else {
            $('#json_wrapper').addClass('warning');
        }
    },
    
    'JSON': {
        valid: function(json)
        {
            try {
                var json = JSON.parse(json);
            } catch(e) {
               return false;
            }
            
            return true;
        }
    }
};