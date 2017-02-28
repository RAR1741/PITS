class Config {
  constructor() {
    console.log("INIT: Config");
  }
  getConfig() {
    console.log("Getting config...");
    $.ajax({
      url: "/config/get/"+getRobotIP(),
    }).done(function(result) {
      console.log(result);
      window.config.loadConfigInEditor(result);
    });
  }
  pushConfig() {
    var confirm = window.confirm("Are you sure you want to push?");
    if (confirm) {
      console.log("Pushing config...");
      $.ajax({
        url: "/config/put/"+getRobotIP(),
        method: "post",
        data: window.editor.getValue()
      }).done(function(result) {
        console.log("Pushed config...");
        console.log(result);
      });
    }
  }
  loadConfigInEditor(config){
    editor.setValue(config);
    editor.gotoLine(0);
  }
}
