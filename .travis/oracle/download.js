// vim: set et sw=2 ts=2:
"use strict";
var env = process.env;
var Promise = require('bluebird');
var Phantom = Promise.promisifyAll(require('node-phantom-simple'));
var PhantomError = require('node-phantom-simple/headless_error');

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
          for (var key in env) {
            if (key.indexOf('ORACLE_LOGIN_') == 0 && env.hasOwnProperty(key)) {
              var name = key.substr(13) + '=';
              form.data = form.data.replace(name, name + env[key]);
            }
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
