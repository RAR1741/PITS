$(function(){
  $("#getLogs").click(function(event){
    console.log("Getting logs...");

    $.ajax({
      url: "/logs",
    }).done(function(result) {
      console.log(result);
    });
  })
});
