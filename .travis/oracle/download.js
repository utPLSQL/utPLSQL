// vim: set et sw=2 ts=2:
"use strict";

var fs = require('fs');

var env = process.env;
var Promise = require('bluebird');
var Phantom = Promise.promisifyAll(require('node-phantom-simple'));
var PhantomError = require('node-phantom-simple/headless_error');

var credentials = Object.keys(env)
  .filter(function (key) { return key.indexOf('ORACLE_LOGIN_') == 0 })
  .map(function (key) { return [key.substr(13), env[key]] });

if (credentials.length <= 0) {
  console.error("Missing ORACLE_LOGIN environment variables!");
  process.exit(1);
}

if (env['ORACLE_ZIP_DIR']) {
  var directory = env['ORACLE_ZIP_DIR'];
  if (!fs.existsSync(directory)) {
    fs.mkdirSync(directory);
  }
  process.chdir(directory);
}

Phantom.createAsync({ parameters: { 'ssl-protocol': 'tlsv1' } }).then(function (browser) {
  browser = Promise.promisifyAll(browser, { suffix: 'Promise' });

  // Configure the browser, open a tab
  return browser
  .addCookiePromise({'name': 'oraclelicense', 'value': "accept-" + env['ORACLE_COOKIE'] + "-cookie", 'domain': '.oracle.com' })
  .then(function () {
    return browser.createPagePromise();
  })
  .then(function (page) {
    page = Promise.promisifyAll(page, { suffix: 'Promise' });

    // Configure the tab
    page.onResourceError = console.error.bind(console);
    return page
    .setPromise('settings.userAgent', env['USER_AGENT']) // PhantomJS configures the UA per tab

    // Request the file, wait for the login page
    .then(function () {
      return page.openPromise("https://edelivery.oracle.com/akam/otn/linux/" + env['ORACLE_FILE']).then(function (status) {
        if (status != 'success') throw "Unable to connect to oracle.com";
        return page.waitForSelectorPromise('input[type=password]', 5000);
      })
      .catch(PhantomError, function (err) {
        return page.getPromise('plainText').then(function (text) {
          console.error("Unable to load login page. Last response was:\n" + text);
          throw err;
        });
      });
    })

    // Export cookies for cURL
    .then(function () {
      return page.getPromise('cookies').then(function (cookies) {
        var data = "";
        for (var i = 0; i < cookies.length; ++i) {
          var cookie = cookies[i];
          data += cookie.domain + "\tTRUE\t" + cookie.path + "\t"
            + (cookie.secure ? "TRUE" : "FALSE") + "\t0\t"
            + cookie.name + "\t" + cookie.value + "\n";
        }
        return Promise.promisifyAll(require('fs')).writeFileAsync(env['COOKIES'], data);
      });
    })

    // Submit the login form using cURL
    .then(function () {
      return page.evaluatePromise(function () {
        var $form = jQuery(document.forms[0]);
        return {
          action: $form.prop('action'),
          data: $form.serialize()
        };
      })
      .then(function (form) {
        return browser.exitPromise().then(function () {
          var unapplied = credentials.filter(function (tuple) {
            var applied = false;
            form.data = form.data.replace(tuple[0] + '=', function (name) {
              applied = true;
              return name + encodeURIComponent(tuple[1]);
            });
            return !applied;
          })
          .map(function (tuple) { return tuple[0] });

          if (unapplied.length > 0) {
            console.warn("Unable to use all ORACLE_LOGIN environment variables: %j", unapplied);
          }

          var cmd = ['curl', [
            '--cookie', env['COOKIES'],
            '--cookie-jar', env['COOKIES'],
            '--data', '@-',
            '--location',
            '--output', require('path').basename(env['ORACLE_FILE']),
            '--user-agent', env['USER_AGENT'],
            form.action
          ]];

          console.info("Executing %j", cmd);

          var child_process = require('child_process');
          var child = child_process.spawn.apply(child_process, cmd.concat({ stdio: ['pipe', 1, 2] }));
          child.on('exit', process.exit);
          child.stdin.end(form.data);
        });
      });
    })
    .catch(function (err) {
      console.error(err);
      browser.on('exit', function () { process.exit(1); });
      browser.exit();
    });
  });
})
.catch(function (err) {
  console.error(err);
  process.exit(1);
});
