
var casper = require("casper").create({
   // verbose: true,
   // logLevel: "debug",
   pageSettings: {
      loadImages: false,
      loadPlugins: false
   }
});

if (casper.cli.args.length < 4) {
   casper.echo("Missing parameters: username password agreementUrl downloadUrl").exit(1);
}

// Script parameters.
var paramUsername = casper.cli.get(0);
var paramPassword = casper.cli.get(1);
var agreementUrl  = casper.cli.get(2);
var downloadUrl   = casper.cli.get(3);
var downloaded    = false;

phantom.addCookie({
      'name': 'oraclelicense',
      'value': '152021',
      'domain': 'oracle.com'
    });

casper.start();
// TODO: Error handling.


// Try to access the download page, wait for redirection and submit the login form.
casper.thenOpen(downloadUrl).waitForUrl(/signon\.jsp$/, function (re) {
   //this.echo("Injecting Login Info");
   this.evaluate(function (username, password) {
      document.getElementById("sso_username").value = username;
      document.getElementById("ssopassword").value = password;
      doLogin(document.LoginForm);
   }, paramUsername, paramPassword);
   // this.capture("Screenshot.png");
});

casper.on("resource.received", function (resource) {
		//this.echo("Received something: " + resource.url);
   if (resource.url.indexOf("AuthParam") !== -1 && !downloaded) {
      //this.echo("DownloadUrl:");
      // Print the download url.
      this.echo(resource.url);
      downloaded = true;
      // TODO: Try to download file from here. this.download is not working because of cross site request.
   }
});

casper.run(function () {
   this.exit();
});
