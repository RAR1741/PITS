$(function(){
  $("#getLogs").click(function(event){
    console.log("Getting logs...");

    var robotIP = $('input[name=robotIP]').filter(':checked' ).val();
    if (robotIP == 'other') {
      robotIP = $('#ip').val();
    }
    console.log(robotIP);
    $.ajax({
      url: "/logs/"+robotIP,
    }).done(function(result) {
      console.log(result);
    });
  });

});
