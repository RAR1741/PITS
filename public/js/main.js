$(function(){

  window.session = new Session(false);
  window.config = new Config();

  setupEditor();

  loadDefaultIP();

  $("#getLogs").click(getLogs);

  $("#getConfig").click(window.config.getConfig);
  $("#pushConfig").click(window.config.pushConfig);
});

function setupEditor() {
  var editor = ace.edit("editor");

  // Change the mode to ini
  var JavaScriptMode = ace.require("ace/mode/ini").Mode;
  editor.session.setMode(new JavaScriptMode());
}

function getLogs() {
  console.log("Getting logs...");

  $.ajax({
    url: "/logs/"+getRobotIP(),
  }).done(function(result) {
    console.log(result);
  });
}

function getRobotIP() {
  var robotIP = $('input[name=robotIP]').filter(':checked' ).val();
  if (robotIP == 'other') {
    robotIP = $('#ip').val();
  }
  session.setItem("defaultIP", robotIP);

  return robotIP
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
