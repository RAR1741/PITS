$(function(){

  window.session = new Session(false);
  window.config = new Config();

  setupEditor();

  loadDefaultIP();

  setTimeout(getStatusLoop, 1000);
  //setStatus();

  $("#getLogs").click(getLogs);

  $("#getConfig").click(window.config.getConfig);
  $("#pushConfig").click(window.config.pushConfig);

  $(document).ajaxSend(function(event, request, settings) {
    if(!settings.url.match("/status")) {
    	$('#loading-indicator').show();
      getStatus(function(time) {});
    }
  });

  $(document).ajaxComplete(function(event, request, settings) {
    if(!settings.url.match("/status")) {
    	$('#loading-indicator').hide();
      getStatus(function(time) {});
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

//passes getStatus a callback to call itself or something
//I don't even know any more
function getStatusLoop() {
  getStatus(function(time) {
    setTimeout(getStatusLoop, time);
  });
}

//callback is a function that is passed the amount of time to wait for
function getStatus(callback) {
  return $.ajax({
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
      callback(1000);
    },
    error: function(arg1, arg2) {
      setStatus('Lost Connection to PITS');
      $('#status').css('color', 'red');
      callback(5000)
    },
  });
}

function setStatus(text) {
  $("#status").text(text);
  $("#load-status").text(text);
}
