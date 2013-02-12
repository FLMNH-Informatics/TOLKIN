	window.onload = function(){
        positionWindow('div_citation');
    }
    function cit_det(citation_id){
        onClick = $('div_citation').show();
        elementID = "div_citation";
        new Ajax.Updater({
            success: 'div_citation',
            failure: 'div_citation'
        }, '/projects/<%=params[:project_id]%>/citations/' + citation_id, {
            asynchronous: true,
            evalScripts: true,
            method: 'get',
            parameters: {
                ajax: true
            }
        });
    }
