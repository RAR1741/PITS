$(function(){

  window.session = new Session(false);

  loadDefaultIP();

  $("#getLogs").click(getLogs);
});

function getLogs() {
  console.log("Getting logs...");

  var robotIP = $('input[name=robotIP]').filter(':checked' ).val();
  if (robotIP == 'other') {
    robotIP = $('#ip').val();
  }

  session.setItem("defaultIP", robotIP);

  // $.ajax({
  //   url: "/logs/"+robotIP,
  // }).done(function(result) {
  //   console.log(result);
  // });
}

function loadDefaultIP() {
  var defaultIP = session.getItem("defaultIP");
  if (defaultIP) {
    if (defaultIP.match(/roborio-\d{1,5}-frc\.local/)) {
      $("input.ip[value='" + defaultIP + "']").prop("checked", true)
    } else {
      $("#ip").val(defaultIP);
      $("input.ip[value='other']").prop("checked", true)
    }
  }
}
