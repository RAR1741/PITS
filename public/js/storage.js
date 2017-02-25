class Session {
  constructor(autoClear) {
    if (autoClear) {
      this.clearValues();
    }
    console.log("INIT: Session");
    this.printValues();
  }
  getItem(key) {
    return localStorage.getItem(key);
  }
  setItem(key, value) {
    localStorage.setItem(key, value);
  }
  removeItem(key) {
    return localStoragee.removeItem(key);
  }
  printValues() {
    if (localStorage.length > 0) {
      console.log("--- KEY:VALUE ---");
      for(var i in localStorage){
        console.log(i + ":" + localStorage[i]);
      }
      console.log("-----------------");
    } else {
      console.log("Nothing in localStorage.");
    }
  }
  clearValues() {
    localStorage.clear();
  }
}
