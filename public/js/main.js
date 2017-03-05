$(function(){

  window.session = new Session(false);
  window.config = new Config();

  setupEditor();

  loadDefaultIP();

  getStatus();
  setTimeout(getStatusLoop, 1000);

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

//passes getStatus a callback to call itself or something
//I don't even know any more
function getStatusLoop() {
  getStatus(function(time) {
    setTimeout(getStatusLoop, time);
  });
}

//callback is a function that is passed the amount of time to wait for
function getStatus(callback = function(time) {}) {
  $.ajax({
    url: "/status",
    dataType: 'json',
    success: function(result) {
      var c = "black";
      if(result.status.match("good")) {
        c = "green";
      } else if (result.status.match("working")) {
        c = "yellow";
      } else if (result.status.match("error")) {
        c = "red";
      }
      setStatus(result.pits_status, c);
      callback(1000);
    },
    error: function(arg1, arg2) {
      setStatus('Lost Connection to PITS', 'red');
      callback(5000)
    },
  });
}

function setStatus(text, color) {
  $("#status").text(text);
  $("#load-status").text(text);
  $('#status').css('color', color);
  $('#load-status').css('color', color);
}
