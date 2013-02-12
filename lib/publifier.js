function publify(page,projectId,ids,path,action,success,afterSuccess){
  page.notifier().working('Changing publicity...');
  new Ajax.Request("/projects/" + projectId + "/" + action,{
    method:     "post",
    parameters: {"path": path, "ids[]": ids, 'conditions': page.selected().toString() },
    onSuccess:function(response){
      page.notifier().success(success);
      if (afterSuccess) afterSuccess();

    },
    onFailure:function(response){ page.notifier().error("Something went wrong.")}
  })
}

function publifyStatus(projectId,path,action,id,afterSuccess){
  new Ajax.Request("/projects/"+projectId+"/"+action+"?path="+path+"&record_id="+id,{
    method: "get",
    onSuccess: function(response){
      if (afterSuccess && response.responseJSON) afterSuccess(response.responseJSON.public_status);
      if (response.responseJSON ) return response.responseJSON.public_status;
    }
  })
}