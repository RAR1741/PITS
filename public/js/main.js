$(function(){

  window.session = new Session(false);
  window.config = new Config();

  setupEditor();

  loadDefaultIP();

  setTimeout(getStatus, 1000);
  //setStatus();

  $("#getLogs").click(getLogs);

  $("#getConfig").click(window.config.getConfig);
  $("#pushConfig").click(window.config.pushConfig);

  $(document).ajaxSend(function(event, request, settings) {
    if(!settings.url.match("/status")) {
    	$('#loading-indicator').show();
      getStatus();
    }
  });

  $(document).ajaxComplete(function(event, request, settings) {
    if(!settings.url.match("/status")) {
    	$('#loading-indicator').hide();
      getStatus();
    }
  });
});

function setupEditor() {
  window.editor = ace.edit("editor");

  // Change the mode to ini
  var JavaScriptMode = ace.require("ace/mode/ini").Mode;
  editor.session.setMode(new JavaScriptMode());
  editor.$blockScrolling = Infinity
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

function getStatus() {

  $.ajax({
    url: "/status",
    dataType: 'json',
    success: function(result) {
      setStatus(result.pits_status);
      var c = "black";
      if(result.status.match("good")) {
        c = "green";
      } else if (result.status.match("working")) {
        c = "yellow";
      } else if (result.status.match("error")) {
        c = "red";
      }
      $('#status').css('color', c);
      setTimeout(getStatus, 1000);
    },
    error: function(arg1, arg2) {
      setStatus('Lost Connection to PITS');
      setTimeout(getStatus, 5000);
    },
  });
}

function setStatus(text) {
  $("#status").text(text);
  $("#load-status").text(text);
}
