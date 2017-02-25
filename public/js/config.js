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
      $("#editor").text(result);
    });
  }
  pushConfig() {
    var confirm = window.confirm("Are you sure you want to push?");
    if (confirm) {
      console.log("Pushing config...");
    }
  }
}
